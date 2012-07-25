def preprocessing
	patch_change :c => 9, :m => 0x7F, :l => 0x00, :p => 0x07
	tempo_change :t => 140.0
end

def play
	@channel = 9

	dr_basic_start
	2.times { dr_basic }
	dr_basic_fill

	#@channel = 12
	#8.times { base_e_root }
end

def dr_basic_start
	#M========================
	note :n => 'C3'
	note :n => 'A#3', :s => 24
	note :n => 'F#3', :s => 24
	#B------------------------
	note :n => 'E3'
	note :n => 'F#3', :s => 24
	note :n => 'F#3', :s => 12
	note :n => 'E3' , :s => 12
	#B------------------------
	note :n => 'C3'
	note :n => 'F#3', :s => 12
	note :n => 'E3' , :s => 12
	note :n => 'C3'
	note :n => 'F#3', :s => 24
	#B------------------------
	note :n => 'E3'
	note :n => 'F#3', :s => 24
	note :n => 'F#3', :s => 24
end                    
                       
def dr_basic
	#M========================
	note :n => 'C3'
	note :n => 'F#3', :s => 24
	note :n => 'F#3', :s => 24
	#B------------------------
	note :n => 'E3'
	note :n => 'F#3', :s => 24
	note :n => 'F#3', :s => 12
	note :n => 'E3' , :s => 12
	#B------------------------
	note :n => 'C3'
	note :n => 'F#3', :s => 12
	note :n => 'E3' , :s => 12
	note :n => 'C3'
	note :n => 'F#3', :s => 24
	#B------------------------
	note :n => 'E3'
	note :n => 'F#3', :s => 24
	note :n => 'F#3', :s => 24
end                    
                       
def dr_basic_fill
	#M========================
	note :n => 'C3'
	note :n => 'F#3', :s => 24
	note :n => 'F#3', :s => 24
	#B------------------------
	note :n => 'E3'
	note :n => 'F#3', :s => 24
	note :n => 'F#3', :s => 12
	note :n => 'E3' , :s => 12
	#B------------------------
	note :n => 'C3'
	note :n => 'F#3', :s => 12
	note :n => 'E3' , :s => 12
	note :n => 'C3'
	note :n => 'F#3', :s => 24
	#B------------------------
	note :n => 'E3' , :s => 12
	note :n => 'E3' , :s => 12
	note :n => 'E3' , :s => 12
	note :n => 'E3' , :s => 12
end

def base_e_root
	#M========================
	note :n => 'E3' , :g => 22, :s => 24
	note :n => 'E3' , :g => 22, :s => 24
	#B------------------------
	note :n => 'E3' , :g => 22, :s => 24
	note :n => 'E3' , :g => 22, :s => 24
	#B------------------------
	note :n => 'E3' , :g => 22, :s => 24
	note :n => 'E3' , :g => 22, :s => 24
	#B------------------------
	note :n => 'E3' , :g => 22, :s => 24
	note :n => 'E3' , :g => 22, :s => 24
end

