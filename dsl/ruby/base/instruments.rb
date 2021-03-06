module Instruments

	@@instruments = {

		#Piano
		
		'Acoustic Piano'          => [0, 0, 0  ],
		'Bright Piano'            => [0, 0, 1  ],
		'Electric Grand Piano'    => [0, 0, 2  ],
		'Honky-tonk Piano'        => [0, 0, 3  ],
		'Electric Piano'          => [0, 0, 4  ],
		'Electric Piano 2'        => [0, 0, 5  ],
		'Harpsichord'             => [0, 0, 6  ],
		'Clavi'                   => [0, 0, 7  ],

		#Chromatic Percussion
		
		'Celesta'                 => [0, 0, 8  ],
		'Glockenspiel'            => [0, 0, 9  ],
		'Musical box'             => [0, 0, 10 ],
		'Vibraphone'              => [0, 0, 11 ],
		'Marimba'                 => [0, 0, 12 ],
		'Xylophone'               => [0, 0, 13 ],
		'Tubular Bell'            => [0, 0, 14 ],
		'Dulcimer'                => [0, 0, 15 ],

		#Organ
		
		'Drawbar Organ'           => [0, 0, 16 ],
		'Percussive Organ'        => [0, 0, 17 ],
		'Rock Organ'              => [0, 0, 18 ],
		'Church organ'            => [0, 0, 19 ],
		'Reed organ'              => [0, 0, 20 ],
		'Accordion'               => [0, 0, 21 ],
		'Harmonica'               => [0, 0, 22 ],
		'Tango Accordion'         => [0, 0, 23 ],

		#Guitar
		
		'Acoustic Guitar (nylon)' => [0, 0, 24 ],
		'Acoustic Guitar (steel)' => [0, 0, 25 ],
		'Electric Guitar (jazz)'  => [0, 0, 26 ],
		'Electric Guitar (clean)' => [0, 0, 27 ],
		'Electric Guitar (muted)' => [0, 0, 28 ],
		'Overdriven Guitar'       => [0, 0, 29 ],
		'Distortion Guitar'       => [0, 0, 30 ],
		'Guitar harmonics'        => [0, 0, 31 ],
		
		#Bass
		
		'Acoustic Bass'           => [0, 0, 32 ],
		'Electric Bass (finger)'  => [0, 0, 33 ],
		'Electric Bass (pick)'    => [0, 0, 34 ],
		'Fretless Bass'           => [0, 0, 35 ],
		'Slap Bass 1'             => [0, 0, 36 ],
		'Slap Bass 2'             => [0, 0, 37 ],
		'Synth Bass 1'            => [0, 0, 38 ],
		'Synth Bass 2'            => [0, 0, 39 ],
		
		#Strings
		
		'Violin'                  => [0, 0, 40 ],
		'Viola'                   => [0, 0, 41 ],
		'Cello'                   => [0, 0, 42 ],
		'Double bass'             => [0, 0, 43 ],
		'Tremolo Strings'         => [0, 0, 44 ],
		'Pizzicato Strings'       => [0, 0, 45 ],
		'Orchestral Harp'         => [0, 0, 46 ],
		'Timpani'                 => [0, 0, 47 ],
		
		#Ensemble 
		
		'String Ensemble 1'       => [0, 0, 48 ],
		'String Ensemble 2'       => [0, 0, 49 ],
		'Synth Strings 1'         => [0, 0, 50 ],
		'Synth Strings 2'         => [0, 0, 51 ],
		'Voice Aahs'              => [0, 0, 52 ],
		'Voice Oohs'              => [0, 0, 53 ],
		'Synth Voice'             => [0, 0, 54 ],
		'Orchestra Hit'           => [0, 0, 55 ],
		
		#Brass 
		
		'Trumpet'                 => [0, 0, 56 ],
		'Trombone'                => [0, 0, 57 ],
		'Tuba'                    => [0, 0, 58 ],
		'Muted Trumpet'           => [0, 0, 59 ],
		'French horn'             => [0, 0, 60 ],
		'Brass Section'           => [0, 0, 61 ],
		'Synth Brass 1'           => [0, 0, 62 ],
		'Synth Brass 2'           => [0, 0, 63 ],
		
		#Reed 
		
		'Soprano Sax'             => [0, 0, 64 ],
		'Alto Sax'                => [0, 0, 65 ],
		'Tenor Sax'               => [0, 0, 66 ],
		'Baritone Sax'            => [0, 0, 67 ],
		'Oboe'                    => [0, 0, 68 ],
		'English Horn'            => [0, 0, 69 ],
		'Bassoon'                 => [0, 0, 70 ],
		'Clarinet'                => [0, 0, 71 ],
		
		#Pipe 
		
		'Piccolo'                 => [0, 0, 72 ],
		'Flute'                   => [0, 0, 73 ],
		'Recorder'                => [0, 0, 74 ],
		'Pan Flute'               => [0, 0, 75 ],
		'Blown Bottle'            => [0, 0, 76 ],
		'Shakuhachi'              => [0, 0, 77 ],
		'Whistle'                 => [0, 0, 78 ],
		'Ocarina'                 => [0, 0, 79 ],
		
		#Synth Lead 
		
		'Lead 1 (square)'         => [0, 0, 80 ],
		'Lead 2 (sawtooth)'       => [0, 0, 81 ],
		'Lead 3 (calliope)'       => [0, 0, 82 ],
		'Lead 4 (chiff)'          => [0, 0, 83 ],
		'Lead 5 (charang)'        => [0, 0, 84 ],
		'Lead 6 (voice)'          => [0, 0, 85 ],
		'Lead 7 (fifths)'         => [0, 0, 86 ],
		'Lead 8 (bass + lead)'    => [0, 0, 87 ],
		
		#Synth Pad 
		
		'Pad 1 (Fantasia)'        => [0, 0, 88 ],
		'Pad 2 (warm)'            => [0, 0, 89 ],
		'Pad 3 (polysynth)'       => [0, 0, 90 ],
		'Pad 4 (choir)'           => [0, 0, 91 ],
		'Pad 5 (bowed)'           => [0, 0, 92 ],
		'Pad 6 (metallic)'        => [0, 0, 93 ],
		'Pad 7 (halo)'            => [0, 0, 94 ],
		'Pad 8 (sweep)'           => [0, 0, 95 ],
		
		#Synth Effects 
		
		'FX 1 (rain)'             => [0, 0, 96 ],
		'FX 2 (soundtrack)'       => [0, 0, 97 ],
		'FX 3 (crystal)'          => [0, 0, 98 ],
		'FX 4 (atmosphere)'       => [0, 0, 99 ],
		'FX 5 (brightness)'       => [0, 0, 100],
		'FX 6 (goblins)'          => [0, 0, 101],
		'FX 7 (echoes)'           => [0, 0, 102],
		'FX 8 (sci-fi)'           => [0, 0, 103],
		
		#Ethnic 
		
		'Sitar'                   => [0, 0, 104],
		'Banjo'                   => [0, 0, 105],
		'Shamisen'                => [0, 0, 106],
		'Koto'                    => [0, 0, 107],
		'Kalimba'                 => [0, 0, 108],
		'Bagpipe'                 => [0, 0, 109],
		'Fiddle'                  => [0, 0, 110],
		'Shanai'                  => [0, 0, 111],
		
		#Percussive' 
		
		'Tinkle Bell'             => [0, 0, 112],
		'Agogo'                   => [0, 0, 113],
		'Steel Drums'             => [0, 0, 114],
		'Woodblock'               => [0, 0, 115],
		'Taiko Drum'              => [0, 0, 116],
		'Melodic Tom'             => [0, 0, 117],
		'Synth Drum'              => [0, 0, 118],
		'Reverse Cymbal'          => [0, 0, 119],
		
		#Sound effects 
		
		'Guitar Fret Noise'       => [0, 0, 120],
		'Breath Noise'            => [0, 0, 121],
		'Seashore'                => [0, 0, 122],
		'Bird Tweet'              => [0, 0, 123],
		'Telephone Ring'          => [0, 0, 124],
		'Helicopter'              => [0, 0, 125],
		'Applause'                => [0, 0, 126],
		'Gunshot'                 => [0, 0, 127],

		#Druns
		
		'Drums'                   => [127, 0, 0]
	}

end
