require 'nkf'

class SMF

  def self.directory
    dir = YAML.load_file("#{$work_dir}/settings.yml")["documens"] || '~/namidi'
    FileUtils.mkdir_p(File.expand_path("#{dir}"), mode: 0755) unless Dir.exists? File.expand_path("#{dir}")
    dir
  end

  def self.read(filename)
    Reader.read(File.expand_path("#{directory}/#{filename}"))
  end

  def self.write(song, filename)
    Writer.write(song, File.expand_path("#{directory}/#{filename}"))
  end

  class Reader
    def self.read(filepath)
      Context.new(filepath).parse
    end

    class Context
      attr_reader :io

      attr_accessor :strategy
      attr_accessor :song

      attr_accessor :resolution
      attr_accessor :track_count
      attr_accessor :track_length
      attr_accessor :step

      attr_accessor :status

      def initialize(filepath)
        @io = File.open(filepath)
        @song = Song.new
      end

      def parse
        strategy = Header
        while End != strategy do
          strategy = strategy.parse(self)
        end
        
        @song.notes.sort_by! { |n| [n.step, n.channel, n.noteno] }
        @song
      end

      def read(length)
        @io.read(length)
      end

      def ungetc(c)
        @io.ungetc(c)
      end

      def seek(amount, whence)
        @io.seek(amount, whence)
      end
    end

    class Header
      def self.parse(ctx)
        raise unless 'MThd' == ctx.read(4)
        raise unless 6 == ctx.read(4).unpack("N").first
        raise unless 1 == ctx.read(2).unpack("n").first
        ctx.track_count = ctx.read(2).unpack("n").first
        ctx.resolution = ctx.read(2).unpack("n").first
        Track
      end
    end

    class Track
      def self.parse(ctx)
        raise unless ctx.read(4) == 'MTrk'
        ctx.track_length = ctx.io.read(4).unpack("N").first
        ctx.step = 0
        DeltaTime
      end
    end

    class Data
      def self.flexible_length(ctx)
        ret = 0
        begin
          b = read(ctx, 1).unpack("C").first
          break unless b
          ret = (ret << 7) + (b & 0x7F)
        end while 0x80 == (b & 0x80)
        ret
      end

      def self.flexible_length_seek(ctx)
        size = flexible_length(ctx)
        ctx.seek(size, IO::SEEK_CUR)
        ctx.track_length -= size
      end

      def self.normalize(ctx, step)
        (step.to_f / (ctx.resolution.to_f / Song::TIME_BASE.to_f)).to_i
      end

      def self.ungetc(ctx, b)
        ctx.track_length += 1
        ctx.ungetc(b)
      end

      def self.read(ctx, size)
        ctx.track_length -= size
        ctx.read(size)
      end

      def self.parse(ctx)
        ctx.strategy = parse_data(ctx)

        if 0 < ctx.track_length
          ctx.strategy
        else
          c = ctx.read(1)
          if c
            ctx.ungetc(c)
            Track
          else
            End
          end
        end
      end
    end

    class DeltaTime < Data
      def self.parse_data(ctx)
        ctx.step += normalize(ctx, flexible_length(ctx))
        Status
      end
    end

    class Status < Data
      def self.parse_data(ctx)
        status = read(ctx, 1).unpack("C").first

        loop do
          case status & 0xF0
          when 0x90
            ctx.status = status
            return NoteOn
          when 0x80
            ctx.status = status
            return NoteOff
          when 0xF0
            ctx.status = status
            if 0xFF == status
              return Meta
            else
              return SysEx
            end
          when 0xA0, 0xB0, 0xE0
            ctx.status = status
            read(ctx, 2)
            return DeltaTime
          when 0xC0, 0xD0
            ctx.status = status
            read(ctx, 1)
            return DeltaTime
          else
            ungetc(ctx, status)
            status = ctx.status
            raise if status.nil? || 0xF0 == status & 0xF0
          end
        end
      end
    end

    class SysEx < Data
      def self.parse_data(ctx)
        flexible_length_seek(ctx)
        DeltaTime
      end
    end

    class Meta < Data
      def self.parse_data(ctx)
        meta = read(ctx, 1).unpack("C").first

        case meta
        when 0x06
          Marker
        when 0x2F
          TrackEnd
        when 0x51
          Tempo
        when 0x58
          Beat
        else
          flexible_length_seek(ctx)
          DeltaTime
        end
      end
    end

    class TrackEnd < Data
      def self.parse_data(ctx)
        read(ctx, 1)
        ctx.track_count -= 1
        if 0 >= ctx.track_count
          End
        else
          Track
        end
      end
    end

    class End
    end

    class NoteMsg < Data
      def self.note_on(ctx, channel, noteno, velocity)
        ctx.song.notes.unshift(Note.new(ctx.step, channel, noteno, velocity, 0))
      end

      def self.note_off(ctx, channel, noteno)
        note = ctx.song.notes.find do |n|
          n.channel == channel && n.noteno == noteno && n.gatetime = 0
        end
        raise unless note
        note.gatetime = ctx.step - note.step
      end
    end

    class NoteOn < NoteMsg
      def self.parse_data(ctx)
        channel = (ctx.status & 0x0F);
        noteno = read(ctx, 1).unpack("C").first
        velocity = read(ctx, 1).unpack("C").first
        if 0 < velocity
          note_on(ctx, channel, noteno, velocity)
        else
          note_off(ctx, channel, noteno)
        end
        DeltaTime
      end
    end

    class NoteOff < NoteMsg
      def self.parse_data(ctx)
        channel = (ctx.status & 0x0F);
        noteno = read(ctx, 1).unpack("C").first
        velocity = read(ctx, 1).unpack("C").first
        note_off(ctx, channel, noteno)
        DeltaTime
      end
    end

    class Marker < Data
      def self.parse_data(ctx)
        len = flexible_length(ctx)
        text = read(ctx, len)
        text.encode!("UTF-8", NKF.guess(text).to_s)
        index = ctx.song.step2measure(ctx.step).index
        ctx.song.set_marker(index, text)
        DeltaTime
      end
    end

    class Tempo < Data
      def self.parse_data(ctx)
        read(ctx, 1)
        micro = ("\x00" + read(ctx, 3)).unpack("N").first
        tempo = 60000000.0 / micro
        index = ctx.song.step2measure(ctx.step).index
        ctx.song.set_tempo(index, tempo)
        DeltaTime
      end
    end

    class Beat < Data
      def self.parse_data(ctx)
        read(ctx, 1)
        numerator = read(ctx, 1).unpack("C").first
        denominator = 2 ** read(ctx, 1).unpack("C").first
        raise unless 24 == read(ctx, 1).unpack("C").first
        raise unless 8 == read(ctx, 1).unpack("C").first
        index = ctx.song.step2measure(ctx.step).index
        ctx.song.set_beat(index, numerator, denominator)
        DeltaTime
      end
    end
  end

  class Writer
    def self.write(song, filepath)
      Context.new(song, filepath).write
    end

    class Context
      attr_reader :io

      attr_accessor :strategy
      attr_accessor :song

      attr_accessor :resolution
      attr_accessor :track_count
      attr_accessor :track_length
      attr_accessor :step

      attr_accessor :status

      def initialize(song, filepath)
        @io = File.open(filepath, 'wb')
        @song = song
      end

      def build_tracks
        @tracks = [meta_track] + note_tracks
      end

      def meta_track
        result = []
        @step = 0
        @song.measures.each do |m|
          if @song.has_marker(m.index)
            result += delta_time(m.step)
            result += marker(m)
          end
          if @song.has_tempo_change(m.index)
            result += delta_time(m.step)
            result += tempo_change(m)
          end
          if @song.has_beat_change(m.index)
            result += delta_time(m.step)
            result += beat_change(m)
          end
          if @song.measures.last == m
            result += delta_time(m.step)
            result += [0xFF, 0x2F, 0x00]
          end
        end
        result
      end

      def note_tracks
        @song.notes.group_by do |n| n.channel
        end.sort_by do |k,v|
          k
        end.map do |k, v|
          with_note_off = []
          v.each do |n|
            with_note_off << n
            with_note_off << n.clone.tap do |n|
              n.step = n.step + n.gatetime
              n.velocity = 0
            end
          end

          with_note_off.sort_by! { |n| [n.step, n.noteno] }

          result = []
          @step = 0
          with_note_off.each do |n|
            result += delta_time(n.step)
            if 0 < n.velocity
              result += [0x90 | n.channel, n.noteno, n.velocity]
            else
              result += [0x80 | n.channel, n.noteno, 0x00]
            end

            if with_note_off.last == n
              result += delta_time(n.step)
              result += [0xFF, 0x2F, 0x00]
            end
          end
          result
        end
      end

      def flexible_length(val)
        b = []

        if 0x1FFFFF < val
          b[0] = (0x80 | (0x000000FF & (val >> 21)))
          b[1] = (0x80 | (0x000000FF & (val >> 14)))
          b[2] = (0x80 | (0x000000FF & (val >> 7)))
          b[3] = ((~0x80) & (0x000000FF & val))
        elsif 0x3FFF < val
          b[0] = (0x80 | (0x000000FF & (val >> 14)))
          b[1] = (0x80 | (0x000000FF & (val >> 7)))
          b[2] = ((~0x80) & (0x000000FF & val))
        elsif 0x7F < val
          b[0] = (0x80 | (0x000000FF & (val >> 7)))
          b[1] = ((~0x80) & (0x000000FF & val))
        else
          b[0] = ((~0x80) & (0x000000FF & val))
        end

        b
      end

      def delta_time(step)
        delta = step - @step
        @step = step

        flexible_length(delta)
      end

      def marker(measure)
        b = [0xFF, 0x06]
        b += flexible_length(measure.marker.bytes.size)
        b += measure.marker.bytes
      end

      def tempo_change(measure)
        micro = (60000000 / measure.tempo).to_i

        b = []
        b[0] = (0x000000FF & (micro >> 16));
        b[1] = (0x000000FF & (micro >> 8));
        b[2] = (0x000000FF & micro);

        [0xFF, 0x51, 0x03] + b
      end

      def beat_change(measure)
        d = measure.denominator
        denominator = 0
        while 1 < d do
          d /= 2
          denominator += 1
        end

        b = []
        b[0] = measure.numerator
        b[1] = denominator

        [0xFF, 0x58, 0x04] + b + [0x18, 0x08]
      end

      def write
        build_tracks
        write_header
        @tracks.each do |t|
          write_track(t)
        end
      end

      def write_header
        @io.write 'MThd'
        @io.write [6].pack("N")
        @io.write [1].pack("n")
        @io.write [@tracks.size].pack("n")
        @io.write [Song::TIME_BASE].pack("n")
      end

      def write_track(track)
        @io.write 'MTrk'
        @io.write [track.size].pack("N")
        @io.write track.pack("C*")
      end
    end

  end
end
