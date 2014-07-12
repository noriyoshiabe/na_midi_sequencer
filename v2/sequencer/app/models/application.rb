require 'observer'

class Application
  include Observable

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

  def exit
    notify(Event::Type::APP, Event::QUIT)
  end

  def notify(type, event)
    changed
    notify_observers(self, type, event)
  end

  def set_channel(channel)
    @editor.set_channel(channel)
  end

  def set_velocity(velocity)
    @editor.set_velocity(velocity)
  end
end
