require 'curses'

class ApplicationController

  def initialize(*args)
    @screen = Screen.new
    @status_view = StatusView.new(@screen, height: @screen.height - 4)
    @piano_roll_view = PianoRollView.new(@screen, y: 2, height: @screen.height - 4)
    @command_view = CommandView.new(@screen, y: @screen.height - 2, height: 2)

    @app = Application.new
    @app.add_observer(self)
    @app.add_observer(@status_view)
    @app.add_observer(@piano_roll_view)
    @app.add_observer(@command_view)
  end

  def run
    loop do
      @screen.render

      c = @screen.getch
      if Curses::KEY_CTRL_Q == c
        break;
      else
        case c
        when ?:
          @command_view.visible = !@command_view.visible
        end
      end
    end

    self
  end

  def update
  end

  def destroy
    @screen.destroy
  end
end
