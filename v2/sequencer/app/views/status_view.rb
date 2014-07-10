require 'view'

class StatusView < View
  
  def initialize(app, parent, layout = {})
    @app = app
    @app.add_observer(self)
    @step_divided = 0
    super(parent, layout)
  end

  def update(app, type, event, *args)
    case type
    when Application::Event::Type::PLAYER
      case event
      when Player::Event::PLAYING_POITION
        step_divided = @app.player.current_step / 7
        if @step_divided != step_divided
          render
        end
        @step_divided = step_divided
      end
    end
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

    if @app.player.running
      infos << "[playing"
      position = @app.song.step2position(@app.player.current_step)
      infos << sprintf("step:%03d:%02d:%03d", position.measure, position.beat + 1, position.tick)
      time_mill = (@app.player.current_time * 1000).to_i
      min = time_mill / 60000
      sec = (time_mill / 1000) % 60
      mill = time_mill % 1000
      infos << sprintf("time:%02d:%02d:%03d]", min, sec, mill)
    end

    setpos(0, 0)
    color(Color::WHITE_BLUE)
    bold
    addstr(" " * self.width)
    setpos(0, 0)
    addstr(infos.join(' ').slice(0...width))
    attroff
  end

end
