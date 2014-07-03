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
  end

  def render
    if @visible
      on_render
      @subviews.map(&:render)
    else
      @window.clear
    end
    @window.refresh
  end

  def on_render
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

  module Color
    WHITE_BLACK = 1
    WHITE_RED = 2
    WHITE_BLUE = 3
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

end

