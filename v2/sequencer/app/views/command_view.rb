require 'view'

class CommandView < View

  def initialize(app, parent, layout = {})
    super(parent, layout)
    @app = app
    @app.add_observer(self)
  end
  
  def on_render
    setpos(0, 0)
    color(Color::WHITE_BLUE)
    bold
    addstr(" " * self.width)
    attroff
  end

  def update(app, type, event, *args)
  end
end
