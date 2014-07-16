require 'view'

class PianoRollView < View

  NOTES_OFFSET_X = 15
  TRACK_OFFSET_Y = 3

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

    @active_track = @track1.activate

    @col_step = 120
    @notes_width = width - NOTES_OFFSET_X
    @offset_step = 0
    @playing_position = 0
  end
  
  def on_render
    clear

    render_frame
    update_viewport
    render_position
    render_measure
  end

  def after_render_child
    render_playing_position
  end

  def render_frame
    setpos(0, 13)
    addstr('|')
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

  def render_position
    measure = @app.song.step2measure(@app.editor.step)

    setpos(0, 0)
    addstr(' ' * 12)
    setpos(0, 0)
    addstr(sprintf("%.2f %d/%d", measure.tempo, measure.numerator, measure.denominator))

    setpos(1, 0)
    addstr(' ' * 12)
    setpos(1, 0)
    position = @app.editor.position
    addstr(sprintf("%03d:%02d:%03d", position.measure, position.beat + 1, position.tick))
  end

  def render_measure
    first_pos = @app.song.step2position(offset_step)
    end_step = offset_step + col_step * notes_width

    line = ' ' * notes_width

    measure_no = first_pos.measure
    measure_no += 1 unless 0 == first_pos.beat && 0 == first_pos.tick
    step = @app.song.measure2step(measure_no)
    while step <= end_step
      index = (step - offset_step) / col_step
      line[index] = measure_no.to_s if 0 <= index && index < notes_width
      measure_no += 1
      step = @app.song.measure2step(measure_no)
    end

    setpos(1, TrackView::NOTES_OFFSET_X)
    addstr(line.slice(0...notes_width))

    line = ' ' * notes_width

    measure_no = first_pos.measure
    measure_no += 1 unless 0 == first_pos.beat && 0 == first_pos.tick
    step = @app.song.measure2step(measure_no)
    while step <= end_step
      index = (step - offset_step) / col_step
      has_tempo_change = @app.song.has_tempo_change(measure_no)
      has_beat_change = @app.song.has_beat_change(measure_no)
      if has_tempo_change || has_beat_change
        measure = @app.song.measure_at(measure_no)
        str = ''
        str += sprintf("%.2f ", measure.tempo) if has_tempo_change
        str += sprintf("%d/%d", measure.numerator, measure.denominator) if has_beat_change
        line[index, str.length] = str
      end
      measure_no += 1
      step = @app.song.measure2step(measure_no)
    end

    setpos(0, TrackView::NOTES_OFFSET_X)
    addstr(line.slice(0...notes_width))
  end

  def render_playing_position
    return unless @app.player.running

    position = playing_position
    return unless 0 <= position && position < notes_width

    color(Color::WHITE_GREEN)
    (0...height).each do |i|
      setpos(i, NOTES_OFFSET_X + position)
      bold
      addch(inch)
    end
    attroff
  end

  def playing_position
    (@app.player.current_step - offset_step) / col_step
  end

  def update(app, type, event, *args)
    case type
    when Application::Event::Type::App
      case event
      when Application::Event::ReadSong
        @active_track.channel = @app.editor.channel
      end
    when Application::Event::Type::Editor
      case event
      when Editor::Event::ChannelChange
        @active_track.channel = @app.editor.channel
      end
    when Application::Event::Type::Player
      case event
      when Player::Event::PlayingPoition
        if @playing_position != playing_position
          render
        end
        @playing_position = playing_position
      end
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

  def switch_track
    @active_track = @active_track.deactivate == @track1 ? @track2.activate : @track1.activate
    @active_track.channel
  end
end

