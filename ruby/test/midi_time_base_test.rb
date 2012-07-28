def preprocessing
	time_base 480
	patch_change :c => 9, :m => 0x7F, :l => 0x00, :p => 0x07
	tempo_change :t => 140.0
end

def play
	@channel = 9

	note :n => 'F#3', :s => 120
	note :n => 'F#3', :s => 120
	note :n => 'F#3', :s => 120
	note :n => 'F#3', :s => 120

	note :n => 'F#3', :s => 120
	note :n => 'F#3', :s => 120
	note :n => 'F#3', :s => 120
	note :n => 'F#3', :s => 120

	note :n => 'A#3', :s => 120
	note :n => 'G#3', :s => 120
	note :n => 'A#3', :s => 120
	note :n => 'G#3', :s => 120

	note :n => 'A#3', :s => 120
	note :n => 'G#3', :s => 120
	note :n => 'A#3', :s => 120
	note :n => 'G#3', :s => 120
end


