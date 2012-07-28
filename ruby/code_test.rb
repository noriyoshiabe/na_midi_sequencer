require 'code'

def preprocessing
	patch_change :c => 9, :m => 0x7F, :l => 0x00, :p => 0x07
	tempo_change :t => 100.0
end

def play
	@channel = 1
	piano_code_play
end


def piano_code_play
	code :rt => 'C', :g => 192, :v => 90

end
