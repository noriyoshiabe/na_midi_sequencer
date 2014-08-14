require 'drums'

def preprocessing
	patch_change :c => 9,  :n => 'Drums'
	patch_change :c => 12, :n => 'Electric Bass (finger)'
	tempo_change :t => 120.0
	@velocity = 127
	@gatetime = 12
end

def play
	@channel = 9
	1.times { dr_basic_start }
	2.times { dr_basic }
	1.times { dr_basic_fill }

	1.times { dr_break }

	1.times { dr_basic_start } 
	2.times { dr_basic }
	1.times { dr_basic_fill }

	@channel = 12
	9.times { base_riff }
end

def dr_basic_start
	#M========================
	note :n => 'Bass Drum1'
	note :n => 'Crash Cymbal1', :s => 24
	note :n => 'Closed Hi-hat', :s => 12
	note :n => 'Bass Drum1',    :s => 12
	#B------------------------
	note :n => 'Snare Drum2'
	note :n => 'Closed Hi-hat', :s => 24
	note :n => 'Bass Drum1'
	note :n => 'Closed Hi-hat', :s => 24
	#B------------------------
	note :n => 'Closed Hi-hat', :s => 24
	note :n => 'Bass Drum1'
	note :n => 'Closed Hi-hat', :s => 24
	#B------------------------
	note :n => 'Snare Drum2'
	note :n => 'Closed Hi-hat', :s => 12
	note :n => 'Bass Drum1',    :s => 12
	note :n => 'Open Hi-hat',   :s => 24
end                    
                       
def dr_basic
	#M========================
	note :n => 'Bass Drum1'
	note :n => 'Closed Hi-hat', :s => 24
	note :n => 'Closed Hi-hat', :s => 12
	note :n => 'Bass Drum1',    :s => 12
	#B------------------------
	note :n => 'Snare Drum2'
	note :n => 'Closed Hi-hat', :s => 24
	note :n => 'Bass Drum1'
	note :n => 'Closed Hi-hat', :s => 24
	#B------------------------
	note :n => 'Closed Hi-hat', :s => 24
	note :n => 'Bass Drum1'
	note :n => 'Closed Hi-hat', :s => 24
	#B------------------------
	note :n => 'Snare Drum2'
	note :n => 'Closed Hi-hat', :s => 12
	note :n => 'Bass Drum1',    :s => 12
	note :n => 'Open Hi-hat',   :s => 24
end                    
                       
def dr_basic_fill
	#M========================
	note :n => 'Bass Drum1'
	note :n => 'Closed Hi-hat', :s => 24
	note :n => 'Closed Hi-hat', :s => 12
	note :n => 'Bass Drum1',    :s => 12
	#B------------------------
	note :n => 'Snare Drum2'
	note :n => 'Closed Hi-hat', :s => 24
	note :n => 'Bass Drum1'
	note :n => 'Closed Hi-hat', :s => 24
	#B------------------------
	note :n => 'Closed Hi-hat', :s => 24
	note :n => 'Bass Drum1'
	note :n => 'Closed Hi-hat', :s => 24
	#B------------------------
	note :n => 'Snare Drum2'
	note :n => 'Closed Hi-hat', :s => 12
	note :n => 'Bass Drum1',    :s => 12
	note :n => 'Open Hi-hat',   :s => 12
	note :n => 'Snare Drum2',   :s => 12
end

def dr_break
	note :n => 'Pedal Hi-hat',  :s => 48
	note :n => 'Pedal Hi-hat',  :s => 48
	note :n => 'Pedal Hi-hat',  :s => 48
	note :n => 'High Tom1',     :s => 8
	note :n => 'Hi-Mid Tom',    :s => 8
	note :n => 'Bass Drum1',    :s => 8
	note :n => 'Snare Drum2',   :s => 0
	note :n => 'Crash Cymbal2', :s => 24
end

def base_riff
	#M========================
	note :n => 'E3', :g => 22, :s => 24
	note :n => 'A2', :g => 10, :s => 12
	note :n => 'E3', :g => 10, :s => 12
	#B------------------------
	note :n => 'G3', :g => 22, :s => 24
	note :n => 'E3', :g => 22, :s => 48
	#B------------------------
	note :n => 'A2', :g => 22, :s => 24
	#B------------------------
	note :n => 'G3', :g => 22, :s => 24
	note :n => 'A3', :g => 22, :s => 24
end

