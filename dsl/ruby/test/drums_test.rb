require 'drums'

def preprocessing
	patch_change :c => 9, :m => 0x7F, :l => 0x00, :p => 0x07
	tempo_change :t => 140.0
end

def play
	@channel = 9

	note :n => 'Pedal Hi-hat'    , :g =>    9, :s =>   49
	note :n => 'Pedal Hi-hat'    , :g =>    6, :s =>   46
	note :n => 'Open Hi-hat'     , :g =>    9, :s =>   48
	note :n => 'Pedal Hi-hat'    , :g =>    7, :s =>   23
	note :n => 'Closed Hi-hat'   , :g =>    6, :s =>   15
	note :n => 'Open Hi-hat'     , :g =>    6, :s =>   19
	note :n => 'Pedal Hi-hat'    , :g =>    5, :s =>   19
	note :n => 'Open Hi-hat'     , :g =>    5, :s =>   40
	note :n => 'Open Hi-hat'     , :g =>    7, :s =>   15
	note :n => 'Low Tom1'        , :g =>    9, :s =>   24
	note :n => 'Open Hi-hat'     , :g =>    8, :s =>   17
	note :n => 'Low Tom1'        , :g =>    6, :s =>   19
	note :n => 'Low Tom1'        , :g =>    9, :s =>   36
	note :n => 'Splash Cymbal'   , :g =>    3, :s =>   13
	note :n => 'Ride Bell'       , :g =>    5, :s =>   13
	note :n => 'Ride Bell'       , :g =>    6, :s =>   12
	note :n => 'Hi-Mid Tom'      , :g =>    8, :s =>   22
	note :n => 'Ride Bell'       , :g =>    6, :s =>   13
	note :n => 'High Tom1'       , :g =>    9, :s =>   17
	note :n => 'Crash Cymbal2'   , :g =>    7, :s =>   48
	note :n => 'Hi-Mid Tom'      , :g =>   17, :s =>   18
	note :n => 'Mid Tom1'        , :g =>    8, :s =>    9
	note :n => 'Mid Tom2'        , :g =>    7, :s =>    8
	note :n => 'Low Tom1'        , :g =>    7, :s =>    8
	note :n => 'Low Tom2'        , :g =>    7, :s =>    8
	note :n => 'Snare Drum2'     , :g =>    6, :s =>    7
	note :n => 'Snare Drum1'     , :g =>    7, :s =>    8
	note :n => 'Bass Drum1'      , :g =>    6, :s =>    7
	note :n => 'Kick Drum2'      , :g =>    6, :s =>   37
	note :n => 'Side Stick'      , :g =>    6, :s =>    7
	note :n => 'Hand Clap'       , :g =>    8, :s =>   16
	note :n => 'Closed Hi-hat'   , :g =>    5, :s =>    5
	note :n => 'Pedal Hi-hat'    , :g =>    4, :s =>   37
	note :n => 'Ride Bell'       , :g =>    6, :s =>  235
	note :n => 'Bass Drum1'      , :g =>    8, :s =>   23
	note :n => 'Hi-Mid Tom'      , :g =>   11, :s =>    2
	note :n => 'Mid Tom1'        , :g =>   27, :s =>   16
	note :n => 'Mid Tom2'        , :g =>   15, :s =>    9
	note :n => 'Low Tom2'        , :g =>    5, :s =>    4
	note :n => 'Low Tom1'        , :g =>   10, :s =>    1
	note :n => 'Snare Drum2'     , :g =>   11, :s =>    9
	note :n => 'Low Tom2'        , :g =>    5, :s =>    2
	note :n => 'Snare Drum1'     , :g =>    3, :s =>    3
	note :n => 'Snare Drum2'     , :g =>    3, :s =>   33
	note :n => 'Hand Clap'       , :g =>    9, :s =>   18
	note :n => 'Closed Hi-hat'   , :g =>    6, :s =>    6
	note :n => 'Pedal Hi-hat'    , :g =>    5, :s =>    6
	note :n => 'Open Hi-hat'     , :g =>    6, :s =>   16
	note :n => 'Side Stick'      , :g =>    4, :s =>    1
	note :n => 'Hi-Mid Tom'      , :g =>   16, :s =>    3
	note :n => 'Hand Clap'       , :g =>    4, :s =>    9
	note :n => 'Low Tom2'        , :g =>    5, :s =>    4
	note :n => 'Mid Tom1'        , :g =>    7, :s =>    8
	note :n => 'Mid Tom2'        , :g =>    9, :s =>    7
	note :n => 'Low Tom1'        , :g =>    6, :s =>    6
	note :n => 'Low Tom2'        , :g =>    4, :s =>    5
	note :n => 'Snare Drum2'     , :g =>    3, :s =>    4
	note :n => 'Snare Drum1'     , :g =>    4, :s =>    4
	note :n => 'Bass Drum1'      , :g =>    2, :s =>    3
	note :n => 'Kick Drum2'      , :g =>    2, :s =>  102
	note :n => 'Mid Tom2'        , :g =>   16, :s =>   15
	note :n => 'Low Tom1'        , :g =>    5, :s =>    6
	note :n => 'Hi-Mid Tom'      , :g =>    3, :s =>    3
	note :n => 'High Tom1'       , :g =>    4, :s =>    5
	note :n => 'Chinese Cymbal'  , :g =>    4, :s =>    4
	note :n => 'Ride Bell'       , :g =>    3, :s =>    4
	note :n => 'Splash Cymbal'   , :g =>    2, :s =>    3
	note :n => 'Crash Cymbal2'   , :g =>    5, :s =>    5
	note :n => 'Ride Cymbal2'    , :g =>   11, :s =>   17
	note :n => 'Open Hi-hat'     , :g =>    6, :s =>    5
	note :n => 'Pedal Hi-hat'    , :g =>    5, :s =>    4
	note :n => 'Closed Hi-hat'   , :g =>    4, :s =>    9
	note :n => 'Hand Clap'       , :g =>    6, :s =>    5
	note :n => 'Side Stick'      , :g =>    8, :s =>    7
	note :n => 'Bass Drum1'      , :g =>   15, :s =>   16
	note :n => 'Snare Drum1'     , :g =>    3, :s =>   14
	note :n => 'Mid Tom1'        , :g =>    5, :s =>    6
	note :n => 'Hi-Mid Tom'      , :g =>   10, :s =>    9
	note :n => 'Mid Tom1'        , :g =>    6, :s =>    5
	note :n => 'Mid Tom2'        , :g =>    6, :s =>    5
	note :n => 'Low Tom1'        , :g =>    4, :s =>    4
	note :n => 'Low Tom2'        , :g =>    6, :s =>    5
	note :n => 'Snare Drum2'     , :g =>    6, :s =>    6
	note :n => 'Snare Drum1'     , :g =>    5, :s =>    4
	note :n => 'Bass Drum1'      , :g =>    4, :s =>    5
	note :n => 'Kick Drum2'      , :g =>    2, :s =>   36
	note :n => 'Mid Tom1'        , :g =>    9, :s =>   10
	note :n => 'Mid Tom2'        , :g =>    3, :s =>    5
	note :n => 'Low Tom1'        , :g =>    3, :s =>   10
	note :n => 'Side Stick'      , :g =>   10
	note :n => 'Hand Clap'       , :g =>   11, :s =>   13
	note :n => 'High Tom1'       , :g =>    7, :s =>    7
	note :n => 'Chinese Cymbal'  , :g =>    5, :s =>    4
	note :n => 'High Tom1'       , :g =>    5, :s =>    2
	note :n => 'Ride Bell'       , :g =>    4, :s =>    1
	note :n => 'Pedal Hi-hat'    , :g =>    4, :s =>    1
	note :n => 'Chinese Cymbal'  , :g =>    4, :s =>    1
	note :n => 'Splash Cymbal'   , :g =>    8, :s =>    1
	note :n => 'Open Hi-hat'     , :g =>    7, :s =>    7
	note :n => 'Crash Cymbal2'   , :g =>    2, :s =>    6
	note :n => 'Crash Cymbal1'   , :g =>    3
	
end

