class ApplicationController

  def initialize(*args)
    @app = Application.new
    @app.add_observer(self)

    @screen = Screen.new
    @status_view = StatusView.new(@app, @screen, height: @screen.height - 4)
    @piano_roll_view = PianoRollView.new(@app, @screen, y: 2, height: @screen.height - 4)
    @command_view = CommandView.new(@app, @screen, y: @screen.height - 2, height: 2)

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
        execute_command(command)
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
