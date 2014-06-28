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

  def update
  end

  def handle_key_input(key)
    case key
    when Key::KEY_CTRL_Q
      notify(Event::Type::APP, Event::QUIT)
    end
  end

  def notify(type, event)
    changed
    notify_observers(self, type, event)
  end
end
