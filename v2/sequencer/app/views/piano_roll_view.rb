require 'view'

class PianoRollView < View
  def on_render
    window.setpos(0, 0)
    window.addstr("-" * self.width)
    window.setpos(0, 1)
    window.addstr("-" * self.width)
    window.setpos(0, 2)
    window.addstr("-" * self.width)
    window.setpos(0, 3)
    window.addstr("-" * self.width)
  end

  def update
  end
end

