class DumpFormatter
	def format(context)
		context.event_list.each do |st, ar|
			ar.each do |h|
				case h[:tp]
				when 'NT'
					printf "ST=%d,TP=NT,C=%d,N=%s,G=%d,V=%d\n", st, h[:c], h[:n], h[:g], h[:v]
				when 'PC'
					printf "ST=%d,TP=PC,C=%d,M=%d,L=%d,P=%d\n", st, h[:c], h[:m], h[:l], h[:p]
				when 'TC'
					printf "ST=%d,TP=TC,T=%f\n", st, h[:t]
				when 'TB'
					printf "ST=%d,TP=TB,T=%d\n", st, h[:t]
				end
			end
		end
	end
end

