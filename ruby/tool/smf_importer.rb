#!/usr/bin/env ruby

class Context
	attr_accessor :abs_step
	attr_accessor :channel
	attr_accessor :note
	attr_accessor :velocity
	attr_accessor :resolution
	attr_accessor :state
	attr_reader :io
	attr_accessor :track_length
	attr_accessor :test
	attr_accessor :last_ch_msg
	
	def initialize(io)
		@io = io
		@events = {}
	end

	def note_on
		h = Hash.new
		h[:abs] = abs_step
		h[:c] = channel
		h[:n] = note
		h[:v] = velocity

		@events[channel] ||= []
		@events[channel] << h
	end

	def note_off
		@events[channel].reverse_each do |h|
			if h[:g].nil?
				h[:g] = abs_step - h[:abs]
				break
			end
		end
	end

	def parse
		@state = @state.parse(self)
	end

	def step(step)
		step / (resolution / 48)
	end

	def event_list
		@events.each do |k,v|
			last = v.last[:abs] + v.last[:g]
			v.reverse_each do |evt|
				evt[:g] = step(evt[:g])
				evt[:s] = step(last - evt[:abs])
				last = evt[:abs]
			end

			if 0 < last
				v.unshift({:s => step(last), :c => v.first[:c], :n => 64, :g => 0, :v => 0})
			end
		end

		@events.sort_by {|k,v| k}
	end

	def format
		event_list.each do |events|
			printf "\t@channel = %d\n\n", events[1].first[:c]
			events[1].each do |e|
				printf "\tnote :n => %d, :g => %d, :v => %d, :s => %d\n", e[:n], e[:g], e[:v], e[:s]
			end
			printf "\n\n"
		end
	end

	# TODO 外出ししたい
	def convert
		table = {
			59 => 36,
			60 => 36,
			61 => 36,
			62 => 40,
			63 => 40,
			64 => 40,
			65 => 37,
			66 => 39,
			67 => 41,
			68 => 45,
			69 => 48,
			70 => 42,
			71 => 44,
			72 => 46,
			73 => 49,
			74 => 51
		}

		@events.each do |k,v|
			v.each do |e|
				e[:n] = table[e[:n]] if 0 == e[:c] && table[e[:n]]
				e[:n] -= 12 if 1 == e[:c]

				e[:c] = 9 if 0 == e[:c]
				e[:c] = 12 if 1 == e[:c]
			end
		end
	end

	# TODO 外出ししたい
	def header
		printf "def preprocessing\n"
		printf "\tpatch_change :c => 9,  :n => 'Drums'\n"
		printf "\tpatch_change :c => 12, :n => 'Electric Bass (pick)'\n"
		printf "\ttempo_change :t => 174.0\n"
		printf "end\n"
		printf "\n"
		printf "def play\n"
		printf "\n"
	end

	def footer
		printf "end\n"
	end
end

class Header
	def self.parse(ctx)
		ctx.io.read(12)
		ctx.resolution = ctx.io.read(2).unpack("n").first
		Track
	end
end

class Track
	def self.parse(ctx)
		raise unless ctx.io.read(4) == 'MTrk'
		ctx.track_length = ctx.io.read(4).unpack("N").first
		ctx.abs_step = 0
		DeltaTime
	end
end

class Data
	def self.flexible_length_number(ctx)
		ret = 0
		begin
			b = read(ctx, 1).unpack("C").first
			break unless b
			ret = (ret << 7) + (b & 0x7F)
		end while 0x80 == (b & 0x80)
		ret
	end

	def self.ungetc(ctx, b)
		ctx.track_length += 1
		ctx.io.ungetc(b)
	end

	def self.read(ctx, size)
		ctx.track_length -= size
		ctx.io.read(size)
	end

	def self.parse(ctx)
		ctx.state = parse_data(ctx)

		if 0 < ctx.track_length
			ctx.state
		else
			c = ctx.io.read(1)
			if c
				ctx.io.ungetc(c)
				Track
			else
				End
			end
		end
	end
end

class DeltaTime < Data
	def self.parse_data(ctx)
		ctx.abs_step += flexible_length_number(ctx)
		StatusTest
	end
end

class StatusTest < Data
	def self.parse_data(ctx)
		ctx.test = read(ctx, 1).unpack("C").first
		Status
	end
end

class Status < Data
	def self.parse_data(ctx)
		case ctx.test & 0xF0
		when 0x90
			ctx.last_ch_msg = ctx.test
			NoteOn
		when 0x80
			ctx.last_ch_msg = ctx.test
			NoteOff
		when 0xF0
			SystemOrMeta
		when 0xA0, 0xB0, 0xE0
			ctx.last_ch_msg = ctx.test
			read(ctx, 2)
			DeltaTime
		when 0xC0, 0xD0
			ctx.last_ch_msg = ctx.test
			read(ctx, 1)
			DeltaTime
		else
			ungetc(ctx, ctx.test)
			ctx.test = ctx.last_ch_msg
			Status
		end
	end
end

class NoteOn < Data
	def self.parse_data(ctx)
		ctx.channel = (ctx.test & 0x0F);
		ctx.note = read(ctx, 1).unpack("C").first
		ctx.velocity = read(ctx, 1).unpack("C").first
		if 0 < ctx.velocity
			ctx.note_on
		else
			ctx.note_off
		end
		DeltaTime
	end
end

class NoteOff < Data
	def self.parse_data(ctx)
		ctx.channel = (ctx.test & 0x0F);
		ctx.note = read(ctx, 1).unpack("C").first
		ctx.velocity = read(ctx, 1).unpack("C").first
		ctx.note_off
		DeltaTime
	end
end

class SystemOrMeta < Data
	def self.flexible_length_seek(ctx)
		size = flexible_length_number(ctx)
		ctx.io.seek(size, IO::SEEK_CUR)
		ctx.track_length -= size
	end

	def self.parse_data(ctx)
		case ctx.test
		when 0xFF
			ctx.test = read(ctx, 1).unpack("C").first
			case ctx.test
			when 0x51 # TODO tempo
				read(ctx, 4)
				DeltaTime
			when 0x58 # TODO beat
				read(ctx, 5)
				DeltaTime
			when 0x2F
				read(ctx, 1)
				Track
			when 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x20, 0x54, 0x59, 0x7F
				read(ctx, 1)
				flexible_length_seek(ctx)
				DeltaTime
			else
				raise 'unexpected format'
			end
		when 0xF0
			read(ctx, 2)
			flexible_length_seek(ctx)
			DeltaTime
		when 0xF2
			read(ctx, 2)
			DeltaTime
		when 0xF1, 0xF3
			read(ctx, 1)
			DeltaTime
		when 0xF6, 0xF7, 0xF8, 0xFA, 0xFB, 0xFC, 0xFE
			DeltaTime
		else
			raise 'unexpected format'
		end
	end
end

class End
end

ctx = Context.new(File.open(ARGV[0], "rb"))
ctx.state = Header
while End != ctx.state do
	ctx.parse
end

ctx.convert
ctx.header
ctx.format
ctx.footer

