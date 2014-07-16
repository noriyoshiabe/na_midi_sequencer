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
          if 1 == candidates.size && command_line =~ /^#{candidates[0].name}\s+/
            tokens = command_line.split
            list = candidates[0].file_list(tokens[1])
          end

          unless list.nil? || list.empty?
            popup(list.slice(0, top), candidates[0].name.length + 2, -list.slice(0, top).size) 
          else
            popup(candidates.map { |c| ":#{c.definition}" }, 0, -candidates.size) 
          end
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
          if 1 == candidates.size
            if 1 == line.split.size
              line = ":#{candidates[0].name} "
            else
              file_list = candidates[0].file_list(line.split[1])
              if 1 == file_list.size
                line = ":#{candidates[0].name} #{file_list[0]}"
              end
            end
          end
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
