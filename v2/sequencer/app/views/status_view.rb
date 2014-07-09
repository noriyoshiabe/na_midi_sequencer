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
    measure = @app.song.step2measure(@app.editor.step)

    infos = []
    infos << "channel:#{@app.editor.channel}"
    infos << "velocity:#{sprintf("%d", @app.editor.velocity)}"
    infos << "quantize:#{@app.editor.quantize_label}"
    infos << "octave:#{@app.editor.octave}"
    infos << "undo:#{0 == @app.editor.undo_stack.size ? '-' : sprintf("%d", @app.editor.undo_stack.size)}"
    infos << "redo:#{0 == @app.editor.redo_stack.size ? '-' : sprintf("%d", @app.editor.redo_stack.size)}"

    setpos(0, 0)
    color(Color::WHITE_BLUE)
    bold
    addstr(" " * self.width)
    setpos(0, 0)
    addstr(infos.join(' ').slice(0...width))
    attroff
  end

end
