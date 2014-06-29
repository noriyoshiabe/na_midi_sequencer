require 'observer'
require 'song'

class Editor
  include Observable

  module Event
    MOVE = 0
    ADD_NOTE = 1
    UNDO = 2
    REDO = 3
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
  attr_accessor :velocity
  attr_accessor :quantize

  def initialize(song)
    @song = song
    @step = 0
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
    @step -= @quantize
    notify(Event::MOVE)
  end

  def add_note(channel, noteno)
    note = Note.new(@step, channel, noteno, @velocity, @quantize - DECAY_MARGIN)
    execute(Command::AddNote.new(self, note))
    notify(Event::ADD_NOTE)
  end

  def execute(cmd)
    cmd.execute
    @undo_stack.push(cmd)
  end

  def undo
    return if @undo_stack.empty?
    cmd = @undo_stack.pop
    cmd.undo
    @redo_stack.push(cmd)
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
      end
      def execute
        @editor.song.add_note(@note)
        @editor.step = @prev_step + @editor.quantize
      end
      def undo
        @editor.song.remove_note(@note)
        @editor.step = @prev_step
      end
    end
  end
end
