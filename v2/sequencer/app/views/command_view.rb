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
    @parser.reset_index

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
              elsif 1 < file_list.size
                cmpl = nil
                file_list.each do |s|
                  cmpl ||= s
                  cmpl = s.split(//).zip(cmpl.split(//)).select{ |e| e.uniq.size==1 }.map{|e| e[0]}.join
                end
                line = ":#{candidates[0].name} #{cmpl}"
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
              ret = @parser.parse(candidate, command_line)
              break
            end
          end
        when Key::KEY_DOWN
          line = ":#{@parser.next.clone}"
        when Key::KEY_UP
          line = ":#{@parser.prev.clone}"
        end
      else
        line << c
      end
    end

    popup_close

    ret
  end
end
