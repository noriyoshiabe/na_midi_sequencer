require 'view'

class CommandView < View

  def initialize(app, parent, layout = {})
    super(parent, layout)
    @app = app
    @app.add_observer(self)
  end
  
  def on_render
    window.setpos(0, 0)
    window.standout
    window.addstr(" " * self.width)
    window.standend
  end

  def update
  end
end
