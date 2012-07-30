#!/usr/bin/env ruby

require 'optparse'

#Add base directory to load paths
$:.unshift File.dirname(__FILE__) + '/base'
#Add extention directory to load paths
$:.unshift File.dirname(__FILE__) + '/extention'
#Add helper directory to load paths
$:.unshift File.dirname(__FILE__) + '/helper'

require 'play_formatter'
require 'dump_formatter'
require 'smf_formatter'

require 'convert_table'
require 'instruments'

class Context
	include ConvertTable
	include Instruments

	def initialize(formatter)
		@formatter = formatter
		@events = []
		@velocity = 100
		@gatetime = 48
		@channel = 1
		@step = 0
		@__events__ = []
		@__st_count__ = []
		@__stack__ = -1
	end

	def note(h)
		note_impl h
		@events << h
	end

	def note_impl(h)
		raise ":n must not be nil" if h[:n].nil?
		h[:n] = convert(h[:n]) unless h[:n].kind_of?(Integer)

		h[:c] ||= @channel
		h[:s] ||= @step
		h[:g] ||= @gatetime
		h[:v] ||= @velocity

		h[:tp] = 'NT'
	end

	def patch_change(h)
		raise if h[:c].nil?
		h = instruments(h) unless h[:n].nil?

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

	def play_synchronized(*args)
		if -1 == @__stack__
			alias org_note note
			undef note
			@__events__ = []
		end
		@__stack__ += 1
		@__st_count__[@__stack__] = 0

		def note(h)
			note_impl h
			h[:st_count] = @__st_count__[@__stack__]
			@__st_count__[@__stack__] += h[:s]
			@__events__ << h
		end

		args.each do |arg|
			@__st_count__[@__stack__] = 0
			send(arg)
		end

		@__stack__ -= 1
		if -1 == @__stack__
			@__events__.sort_by!{|h| h[:st_count]}

			last_st = nil
			@__events__.reverse_each do |h|
				h[:s] = last_st - h[:st_count] unless last_st.nil?
				last_st = h[:st_count]
			end

			@__events__.each do |h|
				org_note h
			end

			undef note
			alias note org_note
		end
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
		@events.unshift({ :c => 0, :tp => 'TB', :t => 48 }) unless @events.index{|e| 'TB' == e[:tp]}

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

	def instruments(h)
		a = @@instruments[h[:n]]
		if a
			h[:m] = a[0]
			h[:l] = a[1]
			h[:p] = a[2]
		end
		h
	end
end

OPTS = {}
OptionParser.new do |opt|
	opt.on('-f [output format]') {|v| OPTS[:f] = v}
	opt.on('-t [smf time base]') {|v| OPTS[:t] = v}
	opt.version = '0.1.0'
	opt.parse!(ARGV)
end

case OPTS[:f]
when 'smf'
	time_base = OPTS[:t] ||= 480
	formatter = SmfFormatter.new(time_base)
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

