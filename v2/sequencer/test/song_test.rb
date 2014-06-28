$:.unshift File.dirname(__FILE__) + '/model'

require 'song'
require 'note'
require 'player'
require 'midi_client'

song = Song.new
puts song.measures
song.set_beat(10, 5, 4)
song.set_beat(90, 3, 4)
song.set_tempo(10, 130.0)
song.set_tempo(80, 145.0)
song.set_tempo(3, 130.0)
puts song.measures

p song.time2step(120.0)
p song.step2time(1979)

song.add_note(Note.new(0, 9, 38, 100, 120))
song.add_note(Note.new(0, 9, 44, 100, 120))
song.add_note(Note.new(480, 9, 40, 100, 120))
song.add_note(Note.new(480, 9, 44, 100, 120))
song.add_note(Note.new(960, 9, 44, 100, 120))
song.add_note(Note.new(1440, 9, 44, 100, 120))
song.add_note(Note.new(1680, 9, 46, 100, 120))


puts song.notes

player = Player.new
player.play(song, 0)
sleep(4)
player.stop
sleep(0.5)
