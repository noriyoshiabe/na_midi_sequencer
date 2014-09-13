require 'observer'

class Player
  include Observable

  attr_reader :current_time
  attr_reader :current_step

  Event = enum [
    :PlayingPoition,
  ]

  def initialize(midi_client)
    @midi_client = midi_client

    @echo_queue = []
    @mutex = Mutex.new
    @cond_val =  ConditionVariable.new

    @current_time = 0.0
    @current_step = 0

    Thread.new do
      echo
    end
  end

  def notify(event)
    changed
    notify_observers(self, event)
  end

  def echo
    echo_off_list = []

    loop do
      @mutex.synchronize do
        @cond_val.wait(@mutex) if @echo_queue.empty? && echo_off_list.empty?
        echo = @echo_queue.shift
        if echo
          @midi_client.note_on(echo[:note])
          echo_off_list.push echo
        end

        now = Time.now
        echo_offs = echo_off_list.select { |e| e[:end_time] <= now }
        echo_offs.each do |e|
          @midi_client.note_off(e[:note])
        end
        
        echo_off_list -= echo_offs
      end

      sleep(0.001)
    end
  end

  def send_echo(song, note)
    @mutex.synchronize do
      @echo_queue.push note: note, end_time: Time.now + (song.step2time(note.step + note.gatetime) - song.step2time(note.step))
      @cond_val.signal if 1 == @echo_queue.size
    end
  end

  def play(song, start_step = 0)
    @running = true
    start_time = Time.now
    Thread.new do
      run(start_time, song, start_step)
    end
  end

  def stop
    @running = false
  end

  def running
    @running
  end

  def run(start_time, song, start_step)
    note_off_list = []

    offset_time = song.step2time(start_step)
    prev_time = offset_time
    while running
      @current_time = (Time.now - start_time) + offset_time

      prev_step = song.time2step(prev_time)
      @current_step = song.time2step(@current_time)

      notes = song.notes_by_range(prev_step, @current_step)
      note_offs = note_off_list.select do |n|
        prev_step <= n.end_step && n.end_step < @current_step
      end

      notes.each do |n|
        @midi_client.note_on(n)
      end

      note_offs.each do |n|
        @midi_client.note_off(n)
      end

      note_off_list -= note_offs
      note_off_list += notes

      prev_time = @current_time
      notify(Event::PlayingPoition) if @current_step != prev_step

      sleep(0.001)
    end

    note_off_list.each do |n|
      @midi_client.note_off(n)
    end
  end
end
