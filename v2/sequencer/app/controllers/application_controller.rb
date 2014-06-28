require 'curses'

class ApplicationController

  def initialize(*args)
    @app = Application.new
    @app.add_observer(self)

    @screen = Screen.new
    @status_view = StatusView.new(@app, @screen, height: @screen.height - 4)
    @piano_roll_view = PianoRollView.new(@app, @screen, y: 2, height: @screen.height - 4)
    @command_view = CommandView.new(@app, @screen, y: @screen.height - 2, height: 2)
  end

  def run
    loop do
      @screen.render

      c = @screen.getch
      if Key::KEY_CTRL_Q == c
        break;
      else
        s = Key.constants.find{ |name|
          /^KEY/ =~ name && Key.const_get(name) == c
        }
        puts (s ? s.to_s : c.to_s)
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
