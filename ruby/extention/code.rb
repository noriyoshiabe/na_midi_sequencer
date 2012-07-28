class Context
	ROOT_NAME_TABLE = {
		'C'   => 0, 'C#' => 1, 'D'   => 2, 'D#' => 3, 'E'   => 4, 'F'   => 5, 'F#' => 6, 'G'   => 7, 'G#' => 8, 'A'   => 9, 'A#' => 10, 'B'   => 11, 
		'Dbb' => 0, 'Db' => 1, 'Ebb' => 2, 'Eb' => 3, 'Fb'  => 4, 'Gbb' => 5, 'Gb' => 6, 'Abb' => 7, 'Ab' => 8, 'Bbb' => 9, 'Bb' => 10, 'Cb'  => 11, 
		'B#'  => 0,            'C##' => 2,            'D##' => 4, 'E#'  => 5,            'F##' => 7,            'G##' => 9,             'A##' => 11, 		
	}

	@@convert_table.merge! ROOT_NAME_TABLE

	SUFFIX_DEFINITIONS = {
		'M'    => [24, 60, 64, 67],
		'm'    => [24, 60, 63, 67],
		'dim'  => [24, 60, 63, 66],
		'aug'  => [24, 60, 64, 68],
		'M7'   => [24, 60, 64, 67, 71],
		'7'    => [24, 60, 64, 67, 70],
		'6'    => [24, 60, 64, 67, 69],
		'mM7'  => [24, 60, 63, 67, 71],
		'm7'   => [24, 60, 63, 67, 70],
		'm6'   => [24, 60, 63, 67, 69],
		'dim7' => [24, 60, 63, 66, 69],
		'aug7' => [24, 60, 64, 68, 70],
	}

	def code(h)
		raise ":rt must not be nil" if h[:rt].nil?

		root_num = convert h[:rt]
		raise ":rt can't be parsed" if root_num.nil?

		suffix = (h[:sf].nil? || h[:sf].empty?) ? 'M' : h[:sf]
		raise ":sf can't be parsed" if !SUFFIX_DEFINITIONS.has_key?(suffix)

		definition = SUFFIX_DEFINITIONS[suffix]
		for i in 0..definition.length-1
			interval = definition[i]
			note :n => root_num + interval, :c => h[:c], :s => (i==definition.length-1) ? h[:s] : 0, :g => h[:g], :v => h[:v]
		end
	end

end