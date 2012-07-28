require 'drums'

def preprocessing
	patch_change :c => 9, :m => 0x7F, :l => 0x00, :p => 0x07
	tempo_change :t => 140.0
end

def play
	@channel = 9

	note :n => 'HH-C', :s => 12
	note :n => 'HH-C', :s => 12
	note :n => 'HH-C', :s => 12
	note :n => 'HH-C', :s => 12

	note :n => 'HH-C', :s => 12
	note :n => 'HH-C', :s => 12
	note :n => 'HH-C', :s => 12
	note :n => 'HH-C', :s => 12

	note :n => 'HH-O', :s => 12
	note :n => 'HH-P', :s => 12
	note :n => 'HH-O', :s => 12
	note :n => 'HH-P', :s => 12

	note :n => 'HH-O', :s => 12
	note :n => 'HH-P', :s => 12
	note :n => 'HH-O', :s => 12
	note :n => 'HH-P', :s => 12

	note :n => 'F#3', :s => 12
	note :n => 'F#3', :s => 12
	note :n => 'F#3', :s => 12
	note :n => 'F#3', :s => 12

	note :n => 'F#3', :s => 12
	note :n => 'F#3', :s => 12
	note :n => 'F#3', :s => 12
	note :n => 'F#3', :s => 12

	note :n => 'A#3', :s => 12
	note :n => 'G#3', :s => 12
	note :n => 'A#3', :s => 12
	note :n => 'G#3', :s => 12

	note :n => 'A#3', :s => 12
	note :n => 'G#3', :s => 12
	note :n => 'A#3', :s => 12
	note :n => 'G#3', :s => 12

	note :n => 'AHO!!'
end

