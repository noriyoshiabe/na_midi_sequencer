#!/usr/bin/env ruby

require 'optparse'

#Add base directory to load paths
$:.unshift File.dirname(__FILE__) + '/base'
#Add extention directory to load paths
$:.unshift File.dirname(__FILE__) + '/extention'

require 'play_formatter'
require 'dump_formatter'

class Context
	def initialize(formatter)
		@formatter = formatter
		@events = []
		@velocity = 100
		@gatetime = 0
		@channel = 1
		@step = 0
	end

	def note(h)
		raise ":n must not be nil" if h[:n].nil?
		h[:n] = convert(h[:n]) unless h[:n].kind_of?(Integer)

		h[:c] ||= @channel
		h[:s] ||= @step
		h[:g] ||= @gatetime
		h[:v] ||= @velocity

		h[:tp] = 'NT'

		@events << h
	end

	def patch_change(h)
		raise if h[:c].nil?
		raise if h[:m].nil?
		raise if h[:l].nil?
		raise if h[:p].nil?

		h[:tp] = 'PC'

		@events << h
	end

	def tempo_change(h)
		raise unless Float === h[:t] || Integer === h[:t]

		h[:c] = 0
		h[:tp] = 'TC'

		@events << h
	end

	def time_base(t)
		raise unless Integer === t
		raise 'time_base has to be called by preprocessing' unless caller.to_s.index 'preprocessing'
		raise 'time_base can not be called twice' unless 0 == @events.select{|e| 'TB' == e[:tp]}.size
		@events.unshift({ :c => 0, :tp => 'TB', :t => t })
	end

	def step_equalize
		@events << { :tp => 'SE' }
	end

	def get_binding
		return binding()
	end

	def preprocessing
		puts '# not overrided preprocessing'
	end

	def play
		puts '# not overrided play'
	end

	def event_list
		table = {}
		st_count = []; 17.times {|i| st_count[i] = 0 }

		@events.each do |h|
			if 'SE' == h[:tp]
				st_count.fill st_count.max
			else
				table[st_count[h[:c]]] ||= []
				table[st_count[h[:c]]] << h
				st_count[h[:c]] += h[:s] unless h[:s].nil?
			end
		end

		table.sort_by{|k, v| k}
	end

	def output
		@formatter.format(self)
	end

	def convert(label)
		ret = @@convert_table[label]
		raise "unknown note label " + label if ret.nil?
		ret
	end

	@@convert_table = {
		'C0' => 0, 'C#0' => 1, 'D0' => 2, 'D#0' => 3, 'E0' => 4, 'F0' => 5, 'F#0' => 6, 'G0' => 7, 'G#0' => 8, 'A0' => 9, 'A#0' => 10, 'B0' => 11, 
		'C1' => 12, 'C#1' => 13, 'D1' => 14, 'D#1' => 15, 'E1' => 16, 'F1' => 17, 'F#1' => 18, 'G1' => 19, 'G#1' => 20, 'A1' => 21, 'A#1' => 22, 'B1' => 23, 
		'C2' => 24, 'C#2' => 25, 'D2' => 26, 'D#2' => 27, 'E2' => 28, 'F2' => 29, 'F#2' => 30, 'G2' => 31, 'G#2' => 32, 'A2' => 33, 'A#2' => 34, 'B2' => 35, 
		'C3' => 36, 'C#3' => 37, 'D3' => 38, 'D#3' => 39, 'E3' => 40, 'F3' => 41, 'F#3' => 42, 'G3' => 43, 'G#3' => 44, 'A3' => 45, 'A#3' => 46, 'B3' => 47, 
		'C4' => 48, 'C#4' => 49, 'D4' => 50, 'D#4' => 51, 'E4' => 52, 'F4' => 53, 'F#4' => 54, 'G4' => 55, 'G#4' => 56, 'A4' => 57, 'A#4' => 58, 'B4' => 59, 
		'C5' => 60, 'C#5' => 61, 'D5' => 62, 'D#5' => 63, 'E5' => 64, 'F5' => 65, 'F#5' => 66, 'G5' => 67, 'G#5' => 68, 'A5' => 69, 'A#5' => 70, 'B5' => 71, 
		'C6' => 72, 'C#6' => 73, 'D6' => 74, 'D#6' => 75, 'E6' => 76, 'F6' => 77, 'F#6' => 78, 'G6' => 79, 'G#6' => 80, 'A6' => 81, 'A#6' => 82, 'B6' => 83, 
		'C7' => 84, 'C#7' => 85, 'D7' => 86, 'D#7' => 87, 'E7' => 88, 'F7' => 89, 'F#7' => 90, 'G7' => 91, 'G#7' => 92, 'A7' => 93, 'A#7' => 94, 'B7' => 95, 
		'C8' => 96, 'C#8' => 97, 'D8' => 98, 'D#8' => 99, 'E8' => 100, 'F8' => 101, 'F#8' => 102, 'G8' => 103, 'G#8' => 104, 'A8' => 105, 'A#8' => 106, 'B8' => 107, 
		'C9' => 108, 'C#9' => 109, 'D9' => 110, 'D#9' => 111, 'E9' => 112, 'F9' => 113, 'F#9' => 114, 'G9' => 115, 'G#9' => 116, 'A9' => 117, 'A#9' => 118, 'B9' => 119, 
		'C10' => 120, 'C#10' => 121, 'D10' => 122, 'D#10' => 123, 'E10' => 124, 'F10' => 125, 'F#10' => 126, 'G10' => 127
	}
end

OPTS = {}
OptionParser.new do |opt|
	opt.on('-f [output format]') {|v| OPTS[:f] = v}
	opt.version = '0.1.0'
	opt.parse!(ARGV)
end

case OPTS[:f]
when 'smf'
	# TODO
when 'dump'
	formatter = DumpFormatter.new
else
	formatter = PlayFormatter.new
end

context = Context.new(formatter)

eval(File.open(ARGV[0]).read, context.get_binding)

context.preprocessing
context.play
context.output

