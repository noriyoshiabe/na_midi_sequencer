require 'view'

class PianoRollView < View

  NOTES_OFFSET_X = 15
  TRACK_OFFSET_Y = 5

  COL_STEPS = [
    20,
    60,
    120,
    240,
    480,
  ]

  attr_reader :col_step
  attr_reader :notes_width
  attr_reader :offset_step

  def initialize(app, parent, layout = {})
    super(parent, layout)
    @app = app
    @app.add_observer(self)

    track_height = height / 2 - 2
    @track1 = TrackView.new(app, self, y: TRACK_OFFSET_Y, height: track_height)
    @track1.channel = 0
    @track2 = TrackView.new(app, self, y: TRACK_OFFSET_Y + track_height + 1, height: track_height)
    @track2.channel = 1

    @active_track = @track1

    @col_step = 120
    @notes_width = width - NOTES_OFFSET_X
    @offset_step = 0
  end
  
  def on_render
    render_frame
    update_viewport
    render_measure_no
  end

  def render_frame
    setpos(0, 0)
    addstr('=' * width)
    setpos(1, 13)
    addstr('|')
    setpos(2, 0)
    addstr('=' * width)
    setpos(@track2.height + 1 + 2, 0)
    addstr('-' * width)
  end

  def update_viewport
    if @offset_step > @app.editor.step
      @offset_step = @app.editor.step
    elsif @app.editor.step > @offset_step + col_step * (notes_width - 1)
      @offset_step += @app.editor.step - (@offset_step + col_step * (notes_width - 1))
    end
  end

  def render_measure_no
    first_pos = @app.song.step2position(offset_step)
    end_step = offset_step + col_step * notes_width

    line = ' ' * notes_width

    measure = first_pos.measure
    measure += 1 unless 0 == first_pos.beat && 0 == first_pos.tick
    step = @app.song.measure2step(measure)
    while step <= end_step
      index = (step - offset_step) / col_step
      line[index] = measure.to_s if 0 <= index && index < notes_width
      measure += 1
      step = @app.song.measure2step(measure)
    end

    setpos(1, TrackView::NOTES_OFFSET_X)
    addstr(line.slice(0...notes_width))
  end

  def update(app, type, event, *args)
    case type
    when Application::Event::Type::EDITOR
    end
  end

  def zoom_in
    return if COL_STEPS.first == @col_step
    @col_step = COL_STEPS[COL_STEPS.index(@col_step) - 1]
  end

  def zoom_out
    return if COL_STEPS.last == @col_step
    @col_step = COL_STEPS[COL_STEPS.index(@col_step) + 1]
  end

  def zoom_reset
    @col_step = 120
  end

  def change_channel(channel)
    @active_track.channel = channel
  end
end

