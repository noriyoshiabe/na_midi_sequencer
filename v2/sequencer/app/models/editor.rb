require 'observer'
require 'song'

class Editor
  include Observable

  Event = enum [
    :StepForward,
    :StepBackward,
    :StepRewind,
    :NoteNoChange,
    :AddNote,
    :RemoveNote,
    :Tie,
    :Untie,
    :Rest,
    :Undo,
    :Redo,
    :OctaveShift,
    :QuantizeChange,
    :ChannelChange,
    :VelocityChange,
    :RecordingChange,
    :ChrodInputChange,
    :Copy,
    :Move,
    :Erase,
    :Delete,
    :Insert,
    :Tempo,
    :Beat,
    :Marker,
  ]

  QUANTIZE_4 = Song::TIME_BASE
  QUANTIZE_8 = Song::TIME_BASE / 2
  QUANTIZE_16 = Song::TIME_BASE / 4
  QUANTIZE_32 = Song::TIME_BASE / 8

  QUANTIZE_4_3 = Song::TIME_BASE * 4 / 3
  QUANTIZE_8_3 = Song::TIME_BASE * 2 / 3
  QUANTIZE_16_3 = Song::TIME_BASE / 3
  QUANTIZE_32_3 = Song::TIME_BASE / 6

  QUANTIZE_4_D = QUANTIZE_4 + QUANTIZE_8
  QUANTIZE_8_D = QUANTIZE_8 + QUANTIZE_16
  QUANTIZE_16_D = QUANTIZE_16 + QUANTIZE_32
  QUANTIZE_32_D = QUANTIZE_32 + QUANTIZE_32 / 2

  QUANTIZES = [
    QUANTIZE_4_D,
    QUANTIZE_4_3,
    QUANTIZE_4,
    QUANTIZE_8_D,
    QUANTIZE_8_3,
    QUANTIZE_8,
    QUANTIZE_16_D,
    QUANTIZE_16_3,
    QUANTIZE_16,
    QUANTIZE_32_D,
    QUANTIZE_32_3,
    QUANTIZE_32,
  ]

  QUANTIZE_LABELS = {
    QUANTIZE_4_D    => '1/4 .',
    QUANTIZE_4_3    => '1/4 3',
    QUANTIZE_4      => '1/4',
    QUANTIZE_8_D    => '1/8 .',
    QUANTIZE_8_3    => '1/8 3',
    QUANTIZE_8      => '1/8',
    QUANTIZE_16_D   => '1/16 .',
    QUANTIZE_16_3   => '1/16 3',
    QUANTIZE_16     => '1/16',
    QUANTIZE_32_D   => '1/32 .',
    QUANTIZE_32_3   => '1/32 3',
    QUANTIZE_32     => '1/32',
  }

  DECAY_MARGIN = 10

  attr_accessor :song
  attr_accessor :step
  attr_accessor :noteno
  attr_accessor :channel
  attr_accessor :velocity
  attr_accessor :quantize
  attr_accessor :octave
  attr_accessor :undo_stack
  attr_accessor :redo_stack
  attr_accessor :recording
  attr_accessor :chord_input

  def initialize(song)
    @song = song
    set_default
  end

  def set_default
    @step = 0
    @noteno = 60
    @channel = 0
    @octave = 3
    @velocity = 100
    @quantize = QUANTIZE_8
    @undo_stack = []
    @redo_stack = []
    @recording = false
    @chord_input = false
    @notes_for_chord = {}
  end

  def notify(event)
    changed
    notify_observers(self, event)
  end

  def forward
    @step += @quantize
    notify(Event::StepForward)
  end

  def backward
    return if 0 == @step
    @step -= @quantize
    @step = 0 if 0 > @step
    notify(Event::StepBackward)
  end

  def forward_measure
    position = @song.step2position(@step)
    @step = @song.measure2step(position.measure + 1)
    notify(Event::StepForward)
  end

  def backward_measure
    position = @song.step2position(@step)
    measure = if 0 == position.beat && 0 == position.tick
                position.measure - 1
              else
                position.measure
              end
    return unless 0 <= measure
    @step = @song.measure2step(measure)
    notify(Event::StepBackward)
  end

  def rewind
    return unless 0 < @step
    @step = 0
    notify(Event::StepRewind)
  end

  def up
    return unless 127 > @noteno
    @noteno += 1
    notify(Event::NoteNoChange)
  end

  def down
    return unless 0 < @noteno
    @noteno -= 1
    notify(Event::NoteNoChange)
  end

  def page_up
    return unless 127 > @noteno
    @noteno = [@noteno + 12, 127].min
    notify(Event::NoteNoChange)
  end

  def page_down
    return unless 0 < @noteno
    @noteno = [@noteno - 12, 0].max
    notify(Event::NoteNoChange)
  end

  def octave_shift_up
    return unless 8 > @octave
    @octave += 1
    notify(Event::OctaveShift)
  end

  def octave_shift_down
    return unless -2 < @octave
    @octave -= 1
    notify(Event::OctaveShift)
  end

  def quantize_up
    return if QUANTIZES.first == @quantize
    @quantize = QUANTIZES[QUANTIZES.index(@quantize) - 1]
    notify(Event::QuantizeChange)
  end

  def quantize_down
    return if QUANTIZES.last == @quantize
    @quantize = QUANTIZES[QUANTIZES.index(@quantize) + 1]
    notify(Event::QuantizeChange)
  end

  def set_channel(channel)
    return if @channel == channel
    @channel = channel
    notify(Event::ChannelChange)
  end

  def set_velocity(velocity)
    return if @velocity == velocity
    @velocity = velocity
    notify(Event::VelocityChange)
  end

  def toggle_rec
    @recording = !@recording
    notify(Event::RecordingChange)
  end

  def toggle_chord_input
    @chord_input = !@chord_input
    @notes_for_chord = {} unless @chord_input
    notify(Event::ChrodInputChange)
  end

  def add_note(key)
    noteno = calc_noteno(key)
    return false unless noteno

    note = Note.new(@step, @channel, noteno, @velocity, @quantize - DECAY_MARGIN)
    @noteno = noteno

    if @recording
      if @chord_input
        @notes_for_chord[@noteno] = note
      else
        execute(Command::AddNote.new(self, [note]))
        notify(Event::AddNote)
      end
    else
      notify(Event::NoteNoChange)
    end

    note
  end

  def commit_notes
    return if @notes_for_chord.empty?

    execute(Command::AddNote.new(self, @notes_for_chord.values))
    notify(Event::AddNote)

    @notes_for_chord = {}
  end

  def calc_noteno(key)
    noteno = (@octave + 2) * 12 + key
    0 <= noteno && noteno <= 127 ? noteno : nil
  end

  def tie
    notes = @song.notes_by_range(@step - DECAY_MARGIN, @step + @quantize, @channel, true).select { |n| @chord_input || n.noteno == @noteno }
    return if notes.empty?

    execute(Command::Tie.new(self, notes))
    notify(Event::Tie)
  end

  def untie
    notes = @song.notes_by_range(@step - @quantize, @step + @quantize, @channel, false).select { |n| @chord_input || n.noteno == @noteno }
    unless notes.empty?
      execute(Command::RemoveNote.new(self, notes, true))
      notify(Event::RemoveNote)
    else
      notes = @song.notes_by_range(@step - @quantize, @step + @quantize, @channel, true).select { |n| @chord_input || n.noteno == @noteno }
      unless notes.empty?
        execute(Command::Untie.new(self, notes))
        notify(Event::Untie)
      else
        backward
      end
    end
  end

  def remove
    notes = @song.notes_by_range(@step, @step + @quantize, @channel, true).select { |n| @chord_input || n.noteno == @noteno }
    unless notes.empty?
      execute(Command::RemoveNote.new(self, notes, false))
      notify(Event::RemoveNote)
    end
  end

  def rest
    @step += @quantize
    notify(Event::Rest)
  end

  def copy(from, length, to, channel, channel_to)
    execute(Command::Copy.new(self, from, length, to, channel, channel_to))
    notify(Event::Copy)
  end

  def move(from, length, to, channel, channel_to)
    execute(Command::Move.new(self, from, length, to, channel, channel_to))
    notify(Event::Move)
  end

  def erase(from, length, channel)
    execute(Command::Erase.new(self, from, length, channel))
    notify(Event::Erase)
  end

  def delete(from, length)
    execute(Command::Delete.new(self, from, length))
    notify(Event::Delete)
  end

  def insert(from, length)
    execute(Command::Insert.new(self, from, length))
    notify(Event::Insert)
  end

  def set_tempo(index, tempo)
    execute(Command::Tempo.new(self, index, tempo))
    notify(Event::Tempo)
  end

  def set_beat(index, numerator, denominator)
    execute(Command::Beat.new(self, index, numerator, denominator))
    notify(Event::Beat)
  end

  def set_marker(index, text)
    execute(Command::Marker.new(self, index, text))
    notify(Event::Marker)
  end

  def execute(cmd)
    cmd.execute
    @undo_stack.push(cmd)
    @redo_stack.clear
  end

  def undo
    return if @undo_stack.empty?
    cmd = @undo_stack.pop
    cmd.undo
    @redo_stack.push(cmd)
    notify(Event::Undo)
  end

  def redo
    return if @redo_stack.empty?
    cmd = @redo_stack.pop
    cmd.execute
    @undo_stack.push(cmd)
    notify(Event::Redo)
  end

  def quantize_label
    QUANTIZE_LABELS[@quantize]
  end

  def position
    @song.step2position(@step)
  end

  module Command
    class Base
      def initialize(editor)
        @editor = editor
      end
    end

    class AddNote < Base
      def initialize(editor, notes)
        super(editor)
        @notes = notes
        @prev_step = @editor.step
        @next_step = @prev_step + @editor.quantize
      end
      def execute
        @notes.each { |n| @editor.song.add_note(n) }
        @editor.step = @next_step
      end
      def undo
        @notes.each { |n| @editor.song.remove_note(n) }
        @editor.step = @prev_step
      end
    end

    class RemoveNote < Base
      def initialize(editor, notes, backword)
        super(editor)
        @notes = notes
        @prev_step = @editor.step
        @next_step = backword ? [0, @prev_step - @editor.quantize].max : @prev_step
      end
      def execute
        @notes.each { |n| @editor.song.remove_note(n) }
        @editor.step = @next_step
      end
      def undo
        @notes.each { |n| @editor.song.add_note(n) }
        @editor.step = @prev_step
      end
    end

    class Tie < Base
      def initialize(editor, notes)
        super(editor)
        @notes = notes
        @quantize = @editor.quantize
        @prev_step = @editor.step
        @next_step = @prev_step + @editor.quantize
      end

      def execute
        @notes.each { |n| n.gatetime += @quantize }
        @editor.step = @next_step
      end

      def undo
        @notes.each { |n| n.gatetime -= @quantize }
        @editor.step = @prev_step
      end
    end

    class Untie < Base
      def initialize(editor, notes)
        super(editor)
        @notes = notes
        @quantize = @editor.quantize
        @prev_step = @editor.step
        @next_step = [0, @prev_step - @editor.quantize].max
      end

      def execute
        @notes.each { |n| n.gatetime -= @quantize }
        @editor.step = @next_step
      end

      def undo
        @notes.each { |n| n.gatetime += @quantize }
        @editor.step = @prev_step
      end
    end

    class Copy < Base
      def initialize(editor, from, length, to, channel, channel_to)
        super(editor)
        step_from = @editor.song.measure2step(from)
        step_from_end = @editor.song.measure2step(from + length)
        step_diff = @editor.song.measure2step(to) - step_from
        notes = @editor.song.notes_by_range(step_from, step_from_end, channel)
        @copied = notes.map do |n|
          copy = n.clone
          copy.step += step_diff
          copy.channel = channel_to if channel_to
          copy
        end
      end

      def execute
        @copied.each do |n|
          @editor.song.add_note(n)
        end
      end

      def undo
        @copied.each do |n|
          @editor.song.remove_note(n)
        end
      end
    end

    class Move < Base
      def initialize(editor, from, length, to, channel, channel_to)
        super(editor)
        step_from = @editor.song.measure2step(from)
        step_from_end = @editor.song.measure2step(from + length)
        @step_moved = @editor.song.measure2step(to) - step_from
        @moved = @editor.song.notes_by_range(step_from, step_from_end, channel)
        @channel_from = channel
        @channel_to = channel_to
      end

      def execute
        @moved.each do |n|
          n.step += @step_moved
          n.channel = @channel_to if @channel_to
        end
      end

      def undo
        @moved.each do |n|
          n.step -= @step_moved
          n.channel = @channel_from if @channel_from
        end
      end
    end

    class Erase < Base
      def initialize(editor, from, length, channel)
        super(editor)
        step_from = @editor.song.measure2step(from)
        step_from_end = @editor.song.measure2step(from + length)
        @eraced = @editor.song.notes_by_range(step_from, step_from_end, channel)
      end

      def execute
        @eraced.each do |n|
          @editor.song.remove_note(n)
        end
      end

      def undo
        @eraced.each do |n|
          @editor.song.add_note(n)
        end
      end
    end

    class Delete < Base
      def initialize(editor, from, length)
        super(editor)
        step_from = @editor.song.measure2step(from)
        step_from_end = @editor.song.measure2step(from + length)
        @step_moved = step_from_end - step_from
        @deleted = @editor.song.notes_by_range(step_from, step_from_end)
        @moved = @editor.song.notes_from(step_from_end)
        @from = from
        @length = length
      end

      def execute
        @deleted_measures = @editor.song.delete_measure(@from, @length)
        @deleted.each { |n| @editor.song.remove_note(n) }
        @moved.each { |n| n.step -= @step_moved }
      end

      def undo
        @moved.each { |n| n.step += @step_moved }
        @deleted.each { |n| @editor.song.add_note(n) }
        @editor.song.insert_measure(@from, @deleted_measures)
      end
    end

    class Insert < Base
      def initialize(editor, from, length)
        super(editor)
        @from = from
        @length = length
      end

      def execute
        @editor.song.insert_measure(@from, @length)

        step_from = @editor.song.measure2step(@from)
        @step_moved = @editor.song.measure2step(@from + @length) - step_from

        @moved = @editor.song.notes_from(step_from)
        @moved.each { |n| n.step += @step_moved }
      end

      def undo
        @moved.each { |n| n.step -= @step_moved }
        @editor.song.delete_measure(@from, @length)
      end
    end

    class Tempo < Base
      def initialize(editor, index, tempo)
        super(editor)
        @index = index
        @tempo = tempo
        @prev_tempo = @editor.song.measure_at(index).tempo
      end

      def execute
        @editor.song.set_tempo(@index, @tempo)
      end

      def undo
        @editor.song.set_tempo(@index, @prev_tempo)
      end
    end

    class Beat < Base
      def initialize(editor, index, numerator, denominator)
        super(editor)
        @index = index
        @numerator = numerator
        @denominator = denominator

        m = @editor.song.measure_at(index)
        @prev_numerator = m.numerator
        @prev_denominator = m.denominator
      end

      def execute
        @editor.song.set_beat(@index, @numerator, @denominator)
      end

      def undo
        @editor.song.set_beat(@index, @prev_numerator, @prev_denominator)
      end
    end

    class Marker < Base
      def initialize(editor, index, text)
        super(editor)
        @index = index
        @text = text

        m = @editor.song.measure_at(index)
        @prev_text = m.marker
      end

      def execute
        @editor.song.set_marker(@index, @text)
      end

      def undo
        @editor.song.set_marker(@index, @prev_text)
      end
    end
  end
end
