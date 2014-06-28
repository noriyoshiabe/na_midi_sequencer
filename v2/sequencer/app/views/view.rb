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
end

