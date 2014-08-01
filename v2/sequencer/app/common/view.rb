class View
  attr_accessor :window
  attr_accessor :subviews
  attr_accessor :visible

  def initialize(parent, layout = {})
    left = layout[:x] || 0
    top = layout[:y] || 0
    width = layout[:width] || parent.width
    height = layout[:height] || parent.height
    @window = parent.window.subwin(height, width, top, left)
    parent.subviews << self
    @subviews = []
    @visible = true
    @parent = parent
    @popup = nil
  end

  def render
    if @visible
      on_render
      @subviews.map(&:render)
    else
      @window.clear
    end

    after_render_child
    @window.refresh
  end

  def on_render
  end

  def after_render_child
  end

  def left
    @window.begx
  end

  def top
    @window.begy
  end

  def width
    @window.maxx
  end

  def height
    @window.maxy
  end

  def destroy
    @subviews.map(&:destroy)
    @window.close
  end

  def getch
    @window.getch
  end

  def refresh
    @window.refresh
  end

  module Color
    WHITE_BLACK = 1
    WHITE_RED = 2
    WHITE_BLUE = 3
    WHITE_GREEN = 4
    WHITE_MAGENTA = 5
    RED_BLACK = 6
    RED_BLUE = 7
  end

  def color(color)
    @window.attron(Curses.color_pair(color))
  end

  def bold
    @window.attron(Curses::A_BOLD)
  end

  def attroff
    @window.attroff(Curses::A_COLOR|Curses::A_BOLD|Curses::A_REVERSE)
  end

  def setpos(*args)
    @window.setpos(*args)
  end

  def addstr(*args)
    @window.addstr(*args)
  end

  def addch(*args)
    @window.addch(*args)
  end

  def inch(*args)
    @window.inch(*args)
  end

  def deleteln
    @window.deleteln
  end

  def keypad(*args) 
    @window.keypad(*args)
  end

  def clear
    (0...height).each do |j|
      setpos(j, 0) 
      addstr(" " * width)
    end
  end

  def popup(lines, offset_x, offset_y, alert = false)
    lines = [lines] if lines.instance_of? String

    if @parent
      @parent.popup(lines, left + offset_x, top + offset_y, alert)
    else
      popup_close if @popup

      width = lines.map(&:length).max
      @popup = @window.subwin(lines.length, width, offset_y, offset_x)
      @popup.attron(alert ? Curses.color_pair(Color::WHITE_RED) : Curses.color_pair(Color::WHITE_MAGENTA))
      lines.each_with_index do |l, i|
        @popup.setpos(i, 0)
        @popup.addstr(sprintf("%-#{width}s", l))
      end
      @popup.attroff(Curses::A_COLOR|Curses::A_BOLD|Curses::A_REVERSE)
      @popup.refresh
    end
  end

  def popup_close
    if @parent
      @parent.popup_close
    elsif @popup
      @popup.close
      @popup = nil
      render
    end
  end
end

