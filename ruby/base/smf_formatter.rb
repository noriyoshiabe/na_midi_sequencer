class SmfFormatter

	def initialize(time_base)
		@output_time_base = time_base
		@tracks = {}
		@buffer = {}
		@abs = 0
	end

	def format(context)
		preproccess context.event_list
		header
		tracks
	end

	def preproccess(el)
		el.each do |st, ar|
			ar.each do |h|
				h[:abs] = st

				tracks = []
				case h[:tp]
				when 'NT'
					h[:tp] = 'N-ON'
					tracks << h
					tracks << {:tp => 'N-OFF', :c => h[:c], :n => h[:n], :abs => st + h[:g]}
				when 'PC'
					tracks << h
				when 'TC'
					h[:c] = 1
					tracks << h
				when 'TB'
					@input_time_base = h[:t]
					next
				end

				@tracks[h[:c]] ||= [] if h[:c]
				@tracks[h[:c]].concat tracks
			end
		end

		@tracks.each do |k, v|
			@buffer[k] = []
			v.sort_by!{|h| h[:abs]}
		end
	end

	def header
		STDOUT.write 'MThd'
		STDOUT.write [6].pack("N")
		STDOUT.write [1].pack("n")
		STDOUT.write [@tracks.size].pack("n")
		STDOUT.write [@output_time_base].pack("n")
	end

	def delta_time(abs)
		delta = (abs - @abs) * (@output_time_base / @input_time_base)
		@abs = abs

		b = []

		if 0x1FFFFF < delta
			b[0] = (0x80 | (0x000000FF & (delta >> 21)))
			b[1] = (0x80 | (0x000000FF & (delta >> 14)))
			b[2] = (0x80 | (0x000000FF & (delta >> 7)))
			b[3] = ((~0x80) & (0x000000FF & delta))
		elsif 0x3FFF < delta
			b[0] = (0x80 | (0x000000FF & (delta >> 14)))
			b[1] = (0x80 | (0x000000FF & (delta >> 7)))
			b[2] = ((~0x80) & (0x000000FF & delta))
		elsif 0x7F < delta
			b[0] = (0x80 | (0x000000FF & (delta >> 7)))
			b[1] = ((~0x80) & (0x000000FF & delta))
		else
			b[0] = ((~0x80) & (0x000000FF & delta))
		end

		b
	end

	def tempo_set(tempo)
		micro = (60000000 / tempo).to_i

		b = []
		b[0] = (0x000000FF & (micro >> 16));
		b[1] = (0x000000FF & (micro >> 8));
		b[2] = (0x000000FF & micro);

		[0xFF, 0x51, 0x03] + b
	end

	def tracks
		@tracks.each do |k,v|
			delta_time 0
			v.each do |h|
				case h[:tp]
				when 'N-ON'
					@buffer[h[:c]].concat delta_time(h[:abs])
					@buffer[h[:c]] << (0x90 | h[:c])
					@buffer[h[:c]] << h[:n]
					@buffer[h[:c]] << h[:v]
				when 'N-OFF'
					@buffer[h[:c]].concat delta_time(h[:abs])
					@buffer[h[:c]] << (0x80 | h[:c])
					@buffer[h[:c]] << h[:n]
					@buffer[h[:c]] << 0x00
				when 'PC'
					@buffer[h[:c]].concat delta_time(h[:abs])
					@buffer[h[:c]] << (0xB0 | h[:c])
					@buffer[h[:c]] << 0x00
					@buffer[h[:c]] << h[:m]

					@buffer[h[:c]].concat delta_time(h[:abs])
					@buffer[h[:c]] << (0xB0 | h[:c])
					@buffer[h[:c]] << 0x00
					@buffer[h[:c]] << h[:l]

					@buffer[h[:c]].concat delta_time(h[:abs])
					@buffer[h[:c]] << (0xC0 | h[:c])
					@buffer[h[:c]] << h[:p]
				when 'TC'
					@buffer[h[:c]].concat delta_time(h[:abs])
					@buffer[h[:c]].concat tempo_set(h[:t])
				end
			end
		end

		@tracks.sort_by{|k, v| k}.each do |k, v|
			STDOUT.write 'MTrk'
			STDOUT.write [@buffer[k].size].pack("N")
			STDOUT.write @buffer[k].pack("C*")
		end
	end
end
