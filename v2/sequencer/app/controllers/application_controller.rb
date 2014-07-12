class ApplicationController

  def initialize(*args)
    @app = Application.new
    @app.add_observer(self)

    @screen = Screen.new
    @piano_roll_view = PianoRollView.new(@app, @screen, y: 0, height: @screen.height - 2)
    @status_view = StatusView.new(@app, @screen, y: @screen.height - 2, height: 1)
    @command_view = CommandView.new(@app, @screen, y: @screen.height - 1, height: 1)

    @exit = false
  end

  def running
    !@exit
  end

  def run
    while running do
      @screen.render

      key = @screen.getch

      unless handle_key_input(key)
        @app.handle_key_input(key)
      end
    end

    self
  end

  def handle_key_input(key)
    case key
    when ?:
      command = @command_view.input_command
      if command
        execute_command(command) and return true
      end
    else
      case @app.state
      when Application::State::Edit
        case key
        when ?+
          @piano_roll_view.zoom_in and return true
        when ?-
          @piano_roll_view.zoom_out and return true
        when ?=
          @piano_roll_view.zoom_reset and return true
        when Key::KEY_CTRL_T
          @app.set_channel(@piano_roll_view.switch_track) and return true
        end
      end
    end

    false
  end

  def execute_command(line)
    tokens = line.split
    return if tokens.empty?
    case tokens[0]
    when 'ch'
      channel = tokens[1].to_i
      @app.set_channel(channel)
      @piano_roll_view.change_channel(channel)
    when 'vel'
      velocity = tokens[1].to_i
      @app.set_velocity(velocity)
    when 'tempo'
      index = tokens[1].to_i
      tempo = tokens[2].to_f
      @app.editor.set_tempo(index, tempo)
    when 'beat'
      index = tokens[1].to_i
      beat = tokens[2].split('/')
      @app.editor.set_beat(index, beat[0].to_i, beat[1].to_i)
    when 'cp'
      from = tokens[1].to_i
      to = tokens[2].to_i
      length = tokens[3].to_i
      channel = tokens[4] ? tokens[4].to_i : nil
      channel_to = tokens[5] ? tokens[5].to_i : nil
      @app.editor.copy(from, to, length, channel, channel_to)
    when 'mv'
      from = tokens[1].to_i
      to = tokens[2].to_i
      length = tokens[3].to_i
      channel = tokens[4] ? tokens[4].to_i : nil
      channel_to = tokens[5] ? tokens[5].to_i : nil
      @app.editor.move(from, to, length, channel, channel_to)
    when 'erase'
      from = tokens[1].to_i
      length = tokens[2].to_i
      channel = tokens[3] ? tokens[3].to_i : nil
      @app.editor.erase(from, length, channel)
    when 'delete'
      from = tokens[1].to_i
      length = tokens[2].to_i
      @app.editor.delete(from, length)
    when 'insert'
      from = tokens[1].to_i
      length = tokens[2].to_i
      @app.editor.insert(from, length)
    when 'read'
      @app.read_song(tokens[1])
    when 'write'
      @app.write_song(tokens[1])
    end
  end

  def update(app, type, event, *args)
    case type
    when Application::Event::Type::APP
      case event
      when Application::Event::QUIT
        @exit = true
      end
    end
  end

  def destroy
    @screen.destroy
  end
end
