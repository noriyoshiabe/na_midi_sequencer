class PlayFormatter
	def format(context)
		context.event_list.each do |st, ar|
			ar.each do |h|
				case h[:tp]
				when 'NT'
					printf "%08dNT%02X%02X%04X%02X\n", st, h[:c] - 1, h[:n], h[:g], h[:v]
				when 'PC'
					printf "%08dPC%02X%02X%02X%02X\n", st, h[:c] - 1, h[:m], h[:l], h[:p]
				when 'TC'
					printf "%08dTCFF%03.2f\n", st, h[:t]
				when 'TB'
					printf "%08dTBFF%03d\n", st, h[:t]
				end
			end
		end
	end
end

