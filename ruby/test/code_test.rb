require 'code'

def preprocessing
	patch_change :c => 9, :m => 0x7F, :l => 0x00, :p => 0x07
	tempo_change :t => 72.0
end

def play
	@channel = 1
	piano_code_play
end


def piano_code_play
	code :rt => 'E',                 :tn => '9',           :vp => 'R||0412356',      :s => 48, :g => 48, :v => 90 
	code :rt => 'D#', :sf => 'dim7',                       :vp => 'open_with_bass',  :s => 48, :g => 48, :v => 90
	code :rt => 'D',  :sf => 'm7',                                                   :s => 48, :g => 48, :v => 90
	code :rt => 'G',  :sf => '7',    :tn => ['b9', 'b13'], :vp => 'close_with_bass', :s => 48, :g => 48, :v => 90
	code :rt => 'C',  :sf => 'M7',   :tn => ['9', '#11'],  :vp => 'R20|3153',       :s => 48, :g => 48, :v => 90

end
