require 'observer'

class Player
  include Observable

  def play(song, start_step = 0)
    @exit = false
    start_time = Time.now
    Thread.new do
      run(start_time, song, start_step)
    end
  end

  def stop
    @exit = true
  end

  def run(start_time, song, start_step)
    note_off_list = []

    offset_time = song.step2time(start_step)
    prev_time = offset_time
    while !@exit
      current_time = (Time.now - start_time) + offset_time

      prev_step = song.time2step(prev_time)
      current_step = song.time2step(current_time)

      notes = song.notes_by_range(prev_step, current_step)
      note_offs = note_off_list.select do |n|
        prev_step <= n.end_step && n.end_step < current_step
      end

      notes.each do |n|
        MidiClient.note_on(n)
      end

      note_offs.each do |n|
        MidiClient.note_off(n)
      end

      note_off_list -= note_offs
      note_off_list += notes

      prev_time = current_time
      sleep(0.001)
    end

    note_off_list.each do |n|
      MidiClient.note_off(n)
    end
  end
end
