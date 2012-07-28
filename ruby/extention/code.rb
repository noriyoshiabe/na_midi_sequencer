class Context
	ROOT_NAME_TABLE = {
		'C'   => 0, 'C#' => 1, 'D'   => 2, 'D#' => 3, 'E'   => 4, 'F'   => 5, 'F#' => 6, 'G'   => 7, 'G#' => 8, 'A'   => 9, 'A#' => 10, 'B'   => 11, 
		'Dbb' => 0, 'Db' => 1, 'Ebb' => 2, 'Eb' => 3, 'Fb'  => 4, 'Gbb' => 5, 'Gb' => 6, 'Abb' => 7, 'Ab' => 8, 'Bbb' => 9, 'Bb' => 10, 'Cb'  => 11, 
		'B#'  => 0,            'C##' => 2,            'D##' => 4, 'E#'  => 5,            'F##' => 7,            'G##' => 9,             'A##' => 11, 		
	}

	@@convert_table.merge! ROOT_NAME_TABLE

	def code(h)
		raise ":rt must not be nil" if h[:rt].nil?

		root_num = convert(h[:rt])
		raise ":rt can't be parsed" if root_num.nil?

		note :n => root_num + 72    , :c => h[:c], :s => h[:s], :g => h[:g], :v => h[:v]
		note :n => root_num + 72 + 4, :c => h[:c], :s => h[:s], :g => h[:g], :v => h[:v]
		note :n => root_num + 72 + 7, :c => h[:c], :s => h[:s], :g => h[:g], :v => h[:v]
	end

end