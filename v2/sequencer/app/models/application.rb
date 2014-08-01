require 'observer'

class Application
  include Observable

  Operation = enum [
    :Quit,
    :Forward,
    :Backward,
    :ForwardMeasure,
    :BackwardMeasure,
    :Rewind,
    :Position,
    :Up,
    :Down,
    :PageUp,
    :PageDown,
    :Undo,
    :Redo,
    :Tie,
    :Untie,
    :Remove,
    :Rest,
    :OctaveUp,
    :OctaveDown,
    :QuantizeUp,
    :QuantizeDown,
    :TogglePlay,
    :ToggleRec,
    :ToggleChordInput,
    :Note,
    :CommitNotes,
    :Channel,
    :Velocity,
    :Tempo,
    :Beat,
    :Marker,
    :Copy,
    :Move,
    :Erase,
    :Delete,
    :Insert,
    :Read,
    :Write,
  ]

  Event = enum [
    :Quit,
    :ReadSong,
    :WriteSong,
    :ReadSongFailed,
    :WriteSongFailed,
  ]

  Event::Type = enum [
    :App,
    :Song,
    :Editor,
    :Player,
  ]

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
    begin
      @song = SMF.read(filename)
      @song.add_observer(self)
      @editor.song = @song
      @editor.set_default
      notify(Event::Type::App, Event::ReadSong)
    rescue => ex
      notify(Event::Type::App, Event::ReadSongFailed, ex.message)
    end
  end

  def write_song(filename)
    begin
      SMF.write(@song, filename)
      notify(Event::Type::App, Event::WriteSong)
    rescue => ex
      notify(Event::Type::App, Event::WriteSongFailed, ex.message)
    end
  end

  def update(sender, event)
    case sender
    when Song
      notify(Event::Type::Song, event)
    when Editor
      notify(Event::Type::Editor, event)
    when Player
      notify(Event::Type::Player, event)
    end
  end

  def quit
    notify(Event::Type::App, Event::Quit)
  end

  def notify(type, event, *args)
    changed
    notify_observers(self, type, event, args)
  end

  def execute(operation, *args)
    args = args[0] if args[0].instance_of? Array

    case operation
    when Operation::Quit
      quit
    when Operation::Forward
      @editor.forward
    when Operation::Backward
      @editor.backward
    when Operation::ForwardMeasure
      @editor.forward_measure
    when Operation::BackwardMeasure
      @editor.backward_measure
    when Operation::Rewind
      @editor.rewind
    when Operation::Position
      @editor.set_position(args[0], args[1], args[2])
    when Operation::Up
      @editor.up
    when Operation::Down
      @editor.down
    when Operation::PageUp
      @editor.page_up
    when Operation::PageDown
      @editor.page_down
    when Operation::Undo
      @editor.undo
    when Operation::Redo
      @editor.redo
    when Operation::Tie
      @editor.tie
    when Operation::Untie
      @editor.untie
    when Operation::Remove
      @editor.remove
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
    when Operation::ToggleRec
      @editor.toggle_rec
    when Operation::ToggleChordInput
      @editor.toggle_chord_input
    when Operation::Channel
      @editor.set_channel(args[0])
    when Operation::Velocity
      @editor.set_velocity(args[0])
    when Operation::Tempo
      @editor.set_tempo(args[0], args[1])
    when Operation::Beat
      @editor.set_beat(args[0], args[1], args[2])
    when Operation::Marker
      @editor.set_marker(args[0], args[1])
    when Operation::Copy
      @editor.copy(args[0], args[1], args[2], args[3], args[4])
    when Operation::Move
      @editor.move(args[0], args[1], args[2], args[3], args[4])
    when Operation::Erase
      @editor.erase(args[0], args[1], args[2])
    when Operation::Delete
      @editor.delete(args[0], args[1])
    when Operation::Insert
      @editor.insert(args[0], args[1])
    when Operation::Note
      note = @editor.add_note(args[0])
      @player.send_echo(@song, note) if note
    when Operation::CommitNotes
      @editor.commit_notes
    when Operation::Read
      read_song(args[0])
    when Operation::Write
      write_song(args[0])
    end
  end
end
