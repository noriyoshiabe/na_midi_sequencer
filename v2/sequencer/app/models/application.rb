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
  attr_accessor :state

  def initialize(*args)
    @song = Song.new
    @editor = Editor.new(song)
    @player = Player.new

    @song.add_observer(self)
    @editor.add_observer(self)
    @player.add_observer(self)

    @state = State::Edit.new(self)

    # TODO
    @editor.channel = 9
  end

  def update(sender, event)
    case sender
    when Song
      notify(Event::Type::SONG, event)
    when Editor
      notify(Event::Type::EDITOR, event)
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
        when Key::KEY_SRIGHT
          @app.editor.forward_measure
        when Key::KEY_SLEFT
          @app.editor.backkward_measure
        when Key::KEY_CTRL_W
          @app.editor.rewind
        when Key::KEY_UP
          @app.editor.up
        when Key::KEY_DOWN
          @app.editor.down
        when Key::KEY_CTRL_U
          @app.editor.undo
        when Key::KEY_CTRL_R
          @app.editor.redo
        when Key::KEY_CTRL_I
          @app.editor.tie
        when ' '
          @app.editor.rest
        when ?>
          @app.editor.octave_shift_up
        when ?<
          @app.editor.octave_shift_down
        when 165
          @app.editor.quantize_up
        when 164
          @app.editor.quantize_down
        when Key::KEY_CTRL_P
          @app.player.running ? @app.player.stop : @app.player.play(@app.song, @app.editor.step)
        else
          note_key = Key::NOTE_MAP[key]
          @app.editor.add_note(note_key) if note_key
        end
      end
    end
  end
end
