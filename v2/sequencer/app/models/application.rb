require 'observer'

class Application
  include Observable

  def self.enum(values)
    Module.new do |mod|
      values.each_with_index{ |v,i| mod.const_set(v, i) }
    end
  end

  Operation = enum [
    :Quit,
    :Forward,
    :Backward,
    :ForwardMeasure,
    :BackwardMeasure,
    :Rewind,
    :Up,
    :Down,
    :Undo,
    :Redo,
    :Tie,
    :Untie,
    :Rest,
    :OctaveUp,
    :OctaveDown,
    :QuantizeUp,
    :QuantizeDown,
    :TogglePlay,
    :SetChannel,
    :SetVelocity,
    :Note,
  ]

  module Event
    module Type
      APP = 0
      SONG = 1
      EDITOR = 2
      PLAYER = 3
    end

    QUIT = 0
    READ_SONG = 1
    WRITE_SONG = 2
  end

  attr_accessor :song
  attr_accessor :editor
  attr_accessor :player

  def initialize(*args)
    @song = Song.new
    @editor = Editor.new(song)
    @player = Player.new

    @song.add_observer(self)
    @editor.add_observer(self)
    @player.add_observer(self)
  end

  def read_song(filename)
    @song = SMF.read(filename)
    @song.add_observer(self)
    @editor.song = @song
    @editor.set_default
    notify(Event::Type::APP, Event::READ_SONG)
  end

  def write_song(filename)
    SMF.write(@song, filename)
    notify(Event::Type::APP, Event::WRITE_SONG)
  end

  def update(sender, event)
    case sender
    when Song
      notify(Event::Type::SONG, event)
    when Editor
      notify(Event::Type::EDITOR, event)
    when Player
      notify(Event::Type::PLAYER, event)
    end
  end

  def quit
    notify(Event::Type::APP, Event::QUIT)
  end

  def notify(type, event)
    changed
    notify_observers(self, type, event)
  end

  def execute(operation, *args)
    case operation
    when Operation::Quit
      quit
    when Operation::Forward
      @editor.forward
    when Operation::Backward
      @editor.backkward
    when Operation::ForwardMeasure
      @editor.forward_measure
    when Operation::BackwardMeasure
      @editor.backkward_measure
    when Operation::Rewind
      @editor.rewind
    when Operation::Up
      @editor.up
    when Operation::Down
      @editor.down
    when Operation::Undo
      @editor.undo
    when Operation::Redo
      @editor.redo
    when Operation::Tie
      @editor.tie
    when Operation::Untie
      @editor.untie
    when Operation::Rest
      @editor.rest
    when Operation::OctaveUp
      @editor.octave_shift_up
    when Operation::OctaveDown
      @editor.octave_shift_down
    when Operation::QuantizeUp
      @editor.quantize_up
    when Operation::QuantizeDown
      @editor.quantize_down
    when Operation::TogglePlay
      @player.running ? @player.stop : @player.play(@song, @editor.step)
    when Operation::SetChannel
      @editor.set_channel(args[0])
    when Operation::SetVelocity
      @editor.set_velocity(args[0])
    when Operation::Note
      note = @editor.add_note(args[0])
      @player.send_echo(@song, note) if note
    end
  end
end
