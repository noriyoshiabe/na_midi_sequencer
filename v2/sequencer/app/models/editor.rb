require 'observer'
require 'song'

class Editor
  include Observable

  module Event
    MOVE = 0
    ADD_NOTE = 1
    TIE = 2
    REST = 3
    UNDO = 4
    REDO = 5
    OCTAVE_SHIFT = 6
  end

  QUANTIZE_4 = Song::TIME_BASE
  QUANTIZE_8 = Song::TIME_BASE / 2
  QUANTIZE_16 = Song::TIME_BASE / 4
  QUANTIZE_32 = Song::TIME_BASE / 8

  QUANTIZE_4_3 = Song::TIME_BASE * 2 / 3
  QUANTIZE_8_3 = Song::TIME_BASE / 3
  QUANTIZE_16_3 = Song::TIME_BASE / 6
  QUANTIZE_32_3 = Song::TIME_BASE / 12

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

  def initialize(song)
    @song = song
    @step = 0
    @noteno = 60
    @channel = 0
    @octave = 3
    @velocity = 100
    @quantize = QUANTIZE_8
    @undo_stack = []
    @redo_stack = []
  end

  def notify(event)
    changed
    notify_observers(self, event)
  end

  def forward
    @step += @quantize
    notify(Event::MOVE)
  end

  def backkward
    return unless @quantize <= @step
    @step -= @quantize
    notify(Event::MOVE)
  end

  def up
    return unless 127 > @noteno
    @noteno += 1
    notify(Event::MOVE)
  end

  def down
    return unless 0 < @noteno
    @noteno -= 1
    notify(Event::MOVE)
  end

  def octave_shift_up
    return unless 8 > @octave
    @octave += 1
    notify(Event::OCTAVE_SHIFT)
  end

  def octave_shift_down
    return unless -2 < @octave
    @octave -= 1
    notify(Event::OCTAVE_SHIFT)
  end

  def add_note(key)
    noteno = calc_noteno(key)
    return unless noteno

    note = Note.new(@step, @channel, noteno, @velocity, @quantize - DECAY_MARGIN)
    execute(Command::AddNote.new(self, note))
    @added_note = note
    @noteno = noteno
    notify(Event::ADD_NOTE)
  end

  def calc_noteno(key)
    noteno = (@octave + 2) * 12 + key
    0 <= noteno && noteno <= 127 ? noteno : nil
  end

  def tie
    return unless @added_note
    execute(Command::Tie.new(self, @added_note))
    notify(Event::TIE)
  end

  def rest
    @added_note = nil
    @step += @quantize
    notify(Event::REST)
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
    @added_note = nil
    notify(Event::UNDO)
  end

  def redo
    return if @redo_stack.empty?
    cmd = @redo_stack.pop
    cmd.execute
    @undo_stack.push(cmd)
    notify(Event::REDO)
  end

  module Command
    class Base
      def initialize(editor)
        @editor = editor
      end
    end

    class AddNote < Base
      def initialize(editor, note)
        super(editor)
        @note = note
        @prev_step = @editor.step
        @next_step = @prev_step + @editor.quantize
      end
      def execute
        @editor.song.add_note(@note)
        @editor.step = @next_step
      end
      def undo
        @editor.song.remove_note(@note)
        @editor.step = @prev_step
      end
    end

    class Tie < Base
      def initialize(editor, note)
        super(editor)
        @note = note
        @quantize = @editor.quantize
        @prev_step = @editor.step
        @next_step = @prev_step + @editor.quantize
      end

      def execute
        @note.gatetime += @quantize
        @editor.step = @next_step
      end

      def undo
        @note.gatetime -= @quantize
        @editor.step = @prev_step
      end
    end
  end
end
