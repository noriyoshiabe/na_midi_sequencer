def preprocessing
	patch_change :c => 9, :m => 0x7F, :l => 0x00, :p => 0x07
	tempo_change :t => 120.0
end

def play
	@channel = 3
	#play_synchronized :piano_l_intro, :piano_r_intro
	play_synchronized :piano_l_intro, :piano_r_intro, :piano_lr_intro

	step_equalize

	#@channel = 1
	#piano_l_intro

	#@channel = 2
	#piano_r_intro

end

def piano_lr_intro
	play_synchronized :piano_l_intro, :piano_r_intro
end

def piano_l_intro
	#M========================
	note :n => 'C2', :g => 48, :s => 12, :v => 110
	note :n => 'G2', :g => 48, :s => 12, :v => 52
	note :n => 'C3', :g => 48, :s => 12, :v => 56
	note :n => 'E3', :g => 48, :s => 12, :v => 68
	#B------------------------
	note :n => 'B3', :g => 48, :s => 12, :v => 72
	note :n => 'C4', :g => 48, :s => 12, :v => 60
	note :n => 'E4', :g => 48, :s => 12, :v => 92
	note :n => 'B4', :g => 48, :s => 12, :v => 110
	#B------------------------
	note :n => 'F#5', :g => 48, :s => 12, :v => 72
	note :n => 'G5',  :g => 48, :s => 12, :v => 80
	note :n => 'E5',  :g => 48, :s => 12, :v => 70
	note :n => 'D5',  :g => 48, :s => 12, :v => 85
	#B------------------------
	note :n => 'F#4', :g => 48, :s => 12, :v => 72
	note :n => 'G4',  :g => 48, :s => 12, :v => 73
	note :n => 'E4',  :g => 48, :s => 12, :v => 68
	note :n => 'D4',  :g => 48, :s => 12, :v => 65

	#M========================
	note :n => 'C1', :g => 192, :s => 0, :v => 89
	note :n => 'C2', :g => 192, :s => 0, :v => 72
end

def piano_r_intro
	#M========================
	note :n => 'E5', :g => 96, :s => 0, :v => 118
	note :n => 'D6', :g => 96, :s => 96, :v => 110
	#B------------------------
	#B------------------------
	note :n => 'E6', :g => 32, :s => 0,  :v => 92
	note :n => 'D7', :g => 32, :s => 32, :v => 96

	note :n => 'D6', :g => 32, :s => 0,  :v => 74
	note :n => 'C7', :g => 32, :s => 32, :v => 80
	
	note :n => 'A6',  :g => 32, :s => 0,  :v => 100
	note :n => 'F#7', :g => 32, :s => 32, :v => 118

	#M========================
	note :n => 'D6', :g => 192, :s => 0, :v => 81
	note :n => 'E6', :g => 192, :s => 0, :v => 81
	note :n => 'B6', :g => 192, :s => 0, :v => 85

end
