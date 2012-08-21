require 'chord'

def preprocessing
	patch_change :c => 1, :m => 0x00, :l => 0x00, :p => 0x00
	patch_change :c => 9, :m => 0x7F, :l => 0x00, :p => 0x07
	tempo_change :t => 72.0
end

def play
	@channel = 1
	piano_chord_play
end


def piano_chord_play
	chord :rt => 'E',  :sf => 'M7',   :tn => '9',           :vp => 'R||0412356',      :s => 48, :g => 48, :v => 90 
	chord :rt => 'D#', :sf => 'dim7',                       :vp => 'open_with_bass',  :s => 48, :g => 48, :v => 90
	chord :rt => 'D',  :sf => 'm7',                                                   :s => 48, :g => 48, :v => 90
	chord :rt => 'G',  :sf => '7',    :tn => ['#9'],        :vp => 'close_with_bass', :s => 48, :g => 48, :v => 90
	chord :rt => 'C',  :sf => 'M7',   :tn => ['9', '#11'],  :vp => 'R20|3153',        :s => 48, :g => 48, :v => 90

end
