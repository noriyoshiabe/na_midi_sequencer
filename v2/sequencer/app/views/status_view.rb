require 'view'

class StatusView < View
  
  def initialize(app, parent, layout = {})
    @app = app
    @app.add_observer(self)
    super(parent, layout)
  end

  def update(app, type, event, *args)
  end

  def on_render
    setpos(0, 0)
    addstr("channel:#{@app.editor.channel}")
    setpos(0, 12)
    addstr("velocity:#{sprintf("%3d", @app.editor.velocity)}")
  end

end
