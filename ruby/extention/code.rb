class Context
	ROOT_NAME_TABLE = {
		'C'   => 0, 'C#' => 1, 'D'   => 2, 'D#' => 3, 'E'   => 4, 'F'   => 5, 'F#' => 6, 'G'   => 7, 'G#' => 8, 'A'   => 9, 'A#' => 10, 'B'   => 11, 
		'Dbb' => 0, 'Db' => 1, 'Ebb' => 2, 'Eb' => 3, 'Fb'  => 4, 'Gbb' => 5, 'Gb' => 6, 'Abb' => 7, 'Ab' => 8, 'Bbb' => 9, 'Bb' => 10, 'Cb'  => 11, 
		'B#'  => 0,            'C##' => 2,            'D##' => 4, 'E#'  => 5,            'F##' => 7,            'G##' => 9,             'A##' => 11, 		
	}

	@@convert_table.merge! ROOT_NAME_TABLE

	SUFFIX_DEFINITIONS = {
		'M'    => [0, 4, 7],
		'm'    => [0, 3, 7],
		'dim'  => [0, 3, 6],
		'aug'  => [0, 4, 8],
		'sus4' => [0, 5, 7],
		'M7'   => [0, 4, 7, 11],
		'7'    => [0, 4, 7, 10],
		'6'    => [0, 4, 7, 9],
		'mM7'  => [0, 3, 7, 11],
		'm7'   => [0, 3, 7, 10],
		'm6'   => [0, 3, 7, 9],
		'dim7' => [0, 3, 6, 9],
		'aug7' => [0, 4, 8, 10],
		'sus7' => [0, 5, 7, 10],
	}

	TENSION_NOTE_ALIAS = {
		'b9'  => 1,
		'9'   => 2,
		'#9'  => 3,
		'11'  => 5,
		'#11' => 6,
		'b13' => 8,
		'13'  => 9,
	}

	BUILT_IN_VOICING_PATTERN_ALIAS = {
		'close'           => '||0123456',
		'open'            => '||0213465',
		'close_with_bass' => 'R||0123456',
		'open_with_bass'  => 'R||0213465',
	}

	def code(h)
		raise ":rt must not be nil" if h[:rt].nil?

		root_num = convert h[:rt]
		raise ":rt can't be parsed" if root_num.nil?

		tension_notes = parse_tention_note(h[:tn])

		suffix = (h[:sf].nil? || h[:sf].empty?) ? 'M' : h[:sf]
		raise ":sf can't be parsed" if !SUFFIX_DEFINITIONS.has_key?(suffix)
		definition = SUFFIX_DEFINITIONS[suffix]
		definition += tension_notes

		voicing_pattern = ''
		if !h[:vp].nil? && !h[:vp].empty?
			built_in = BUILT_IN_VOICING_PATTERN_ALIAS[h[:vp]]
			voicing_pattern = built_in.nil? ? h[:vp] : built_in
		else
			voicing_pattern = 'R||0123456'
		end

		notes = create_voicing(root_num, definition, voicing_pattern)
		p notes

		for i in 0..notes.length-1
			n = notes[i]
			note :n => n, :c => h[:c], :s => (i==notes.length-1) ? h[:s] : 0, :g => h[:g], :v => h[:v]
		end
	end

	def parse_tention_note(input)
		result = []

		if input.kind_of?(String)
			tention_num = TENSION_NOTE_ALIAS[input]
			raise ":tn can't be parsed" if tention_num.nil?
			result << tention_num
		elsif input.kind_of?(Array)
			input.each {|s|
				tention_num = TENSION_NOTE_ALIAS[s]
				raise ":tn can't be parsed" if tention_num.nil?
				result << tention_num
			}
		elsif input.nil?
			return []
		else
			raise ":tn must be String or Array"
		end

		result
	end

	def create_voicing(root_num, suffix_definition, voicing_pattern)
		result = []
		current_octave = 24
		current_note = 0

		voicing_pattern.each_char {|c|
			c = '0' if 'R' == c 
			
			case c
			when /[0-9]/
				current_note = suffix_definition[c.to_i]
				next if current_note.nil?
				current_note += root_num
			when '|'
				current_octave += 12
				next
			else
				raise ':vp voicing pattern is invalid string'
			end
			if !result.last.nil?
				until result.last <= current_note + current_octave
					current_octave += 12
				end
			end
			
			result << current_note + current_octave
		}

		result
	end
end