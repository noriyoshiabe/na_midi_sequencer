require 'view'

class CommandView < View
  def on_render
    window.setpos(0, 0)
    window.standout
    window.addstr(" " * self.width)
    window.standend
  end

  def update
  end
end
