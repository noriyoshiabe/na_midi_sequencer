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

    @state = State::Edit.new(self)
  end

  def update(sender, event)
    case sender
    when Song
      notify(Event::Type::SONG, event)
    end
  end

  def handle_key_input(key)
    Log.debug(Key.name(key))
    
    case key
    when Key::KEY_CTRL_Q
      notify(Event::Type::APP, Event::QUIT)
    else
      @state.handle_key_input(key)
    end
  end

  def notify(type, event)
    changed
    notify_observers(self, type, event)
  end

  module State
    class Base
      def initialize(app)
        @app = app
      end
    end

    class Edit < Base
      def handle_key_input(key)
        case key
        when Key::KEY_RIGHT
          @app.editor.forward
        when Key::KEY_LEFT
          @app.editor.backkward
        when Key::KEY_CTRL_U
          @app.editor.undo
        when Key::KEY_CTRL_R
          @app.editor.redo
        when ?c
          @app.editor.add_note(9, 40)
        end
      end
    end
  end
end
