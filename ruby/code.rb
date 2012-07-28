class Context

	def code(h)
		raise if h[:rt].nil?

		note :n => 'C4', :c => h[:c], :s => h[:s], :g => h[:g], :v => h[:v]
		note :n => 'E4', :c => h[:c], :s => h[:s], :g => h[:g], :v => h[:v]
		note :n => 'G4', :c => h[:c], :s => h[:s], :g => h[:g], :v => h[:v]
	end

end