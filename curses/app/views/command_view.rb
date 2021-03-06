require 'view'

class CommandView < View

  attr_accessor :key_name

  def initialize(app, parent, layout = {})
    super(parent, layout)
    @app = app
    @app.add_observer(self)
    @parser = CommandParser.new
    @key_name = ''

    keypad(true)
  end
  
  def on_render
    render_keyname
  end

  def render_keyname
    attroff
    setpos(0, width - 20)
    addstr(' ' * 20)
    setpos(0, width - (@key_name.length + 2))
    addstr("[#{@key_name}]")
  end

  def update(app, type, event, *args)
    case type
    when Application::Event::Type::App
      case event
      when Application::Event::ReadSongFailed, Application::Event::WriteSongFailed
        popup(args[0], 0, 0, true)
      when Application::Event::Quit
        @parser.save_history
      end
    end
  end

  def input_command
    setpos(0,0)
    line = ':'
    cursor = 1
    ret = false
    error = nil
    @parser.reset_index

    loop do
      deleteln
      break if line.empty?

      attroff
      setpos(0,0)
      addstr(line)

      color(Color::WHITE_RED)
      setpos(0, cursor)
      addch(inch)

      command_line = line[1..-1]
      command_head = line[1...cursor]

      candidates = @parser.candidates(command_head)
      unless error
        unless candidates.empty?
          if 1 == candidates.size && command_head =~ /^#{candidates[0].name}\s+/
            tokens = command_head.split
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

      render_keyname
      c = getch
      @key_name = Key.name(c)

      case c
      when Fixnum
        case c
        when 27
          line.clear
        when 127
          cursor -= 1 unless 1 >= cursor
          line.slice!(cursor)
        when Key::KEY_DC
          line.slice!(cursor)
        when Key::KEY_CTRL_I
          if 1 == candidates.size
            head = line[0..cursor]
            tail = line[cursor..-1]

            if 1 == head.split.size
              head = ":#{candidates[0].name} "
              cursor = head.size
              line = head + tail
            else
              file_list = candidates[0].file_list(head.split[1])
              if file_list
                if 1 == file_list.size
                  head = ":#{candidates[0].name} #{file_list[0]}"
                  cursor = head.size
                  line = head + tail
                elsif 1 < file_list.size
                  cmpl = nil
                  file_list.each do |s|
                    cmpl ||= s
                    brk = false
                    cmpl = s.split(//).zip(cmpl.split(//)).select{ |e| res = e.uniq.size==1 && !brk; brk = !res; res }.map{|e| e[0]}.join
                  end
                  head = ":#{candidates[0].name} #{cmpl}"
                  cursor = head.size
                  line = head + tail
                end
              end
            end
          elsif 1 < candidates.size
            cmpl = nil
            candidates.each do |c|
              cmpl ||= c.name
              brk = false
              cmpl = c.name.split(//).zip(cmpl.split(//)).select{ |e| res = e.uniq.size==1 && !brk; brk = !res; res }.map{|e| e[0]}.join
            end
            head = ":#{cmpl}"
            cursor = head.size
            line = head
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
          if @parser.has_next
            line = ":#{@parser.next.clone}"
            cursor = line.size
          end
        when Key::KEY_UP
          if @parser.has_prev
            line = ":#{@parser.prev.clone}"
            cursor = line.size
          end
        when Key::KEY_RIGHT
          cursor += 1 unless line.size <= cursor
        when Key::KEY_LEFT
          cursor -= 1 unless 1 >= cursor
        end
      else
        line.insert(cursor, c)
        cursor += 1
      end
    end

    popup_close

    ret
  end
end
