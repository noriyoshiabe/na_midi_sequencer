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
    setpos(0, 26)
    addstr("quantize:#{@app.editor.quantize_label}")
    setpos(0, 40)
    position = @app.editor.position
    addstr("position:#{sprintf("%03d:%02d:%03d", position.measure, position.beat, position.tick)}")
    setpos(0, 60)
    addstr("octave:#{@app.editor.octave}")
    setpos(0, 70)
    addstr("undo:#{0 == @app.editor.undo_stack.size ? ' - ' : sprintf("%3d", @app.editor.undo_stack.size)}")
    setpos(0, 80)
    addstr("redo:#{0 == @app.editor.redo_stack.size ? ' - ' : sprintf("%3d", @app.editor.redo_stack.size)}")
  end

end
