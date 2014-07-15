require 'view'

class CommandView < View

  def initialize(app, parent, layout = {})
    super(parent, layout)
    @app = app
    @app.add_observer(self)
    @parser = CommandParser.new

    keypad(true)
  end
  
  def on_render
  end

  def update(app, type, event, *args)
  end

  def input_command
    setpos(0,0)
    line = ':'
    ret = false
    error = nil

    loop do
      deleteln
      break if line.empty?

      setpos(0,0)
      addstr(line)

      command_line = line[1..-1]

      unless error
        candidates = @parser.candidates(command_line)
        unless candidates.empty?
          popup(candidates.map { |c| ":#{c.definition}" }, 0, -candidates.size) 
        else
          popup_close
        end
      end

      error = nil
      case c = getch
      when Fixnum
        case c
        when 27
          line.clear
        when 127
          line.chop!
        when Key::KEY_CTRL_I
          line = ":#{candidates[0].name} " if 1 == candidates.size && 1 == line.split.size
        when Key::KEY_CTRL_J
          if 1 != candidates.size
            popup("The command line is incomplete.", 0, -1, true)
            error = true
          else
            candidate = candidates[0]
            error = candidate.syntax_error(command_line)
            if error
              popup("Syntax error.", 0, -1, true)
            else
              deleteln
              ret = candidate.command(command_line)
              break
            end
          end
        end
      else
        line << c
      end
    end

    popup_close

    ret
  end
end
