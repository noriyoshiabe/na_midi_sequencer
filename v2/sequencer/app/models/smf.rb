class SMF

  def self.read(filename)
    Reader.read(filename)
  end

  class Reader
    def self.read(filename)
      # TODO: should be configurable
      Context.new(File.expand_path("~/namidi/#{filename}")).parse
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
end
