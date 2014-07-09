require 'view'

class CommandView < View

  def initialize(app, parent, layout = {})
    super(parent, layout)
    @app = app
    @app.add_observer(self)

    keypad(true)
  end
  
  def on_render
  end

  def update(app, type, event, *args)
  end

  def input_command
    setpos(0,0)
    line = ':'
    loop do
      deleteln
      break if line.empty?

      setpos(0,0)
      addstr(line)

      case c = getch
      when Fixnum
        case c
        when 27
          line.clear
        when 127
          line.chop!
        when Key::KEY_CTRL_J
          deleteln
          return line[1..-1]
        end
      else
        line << c
      end
    end

    false
  end
end
