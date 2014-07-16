require 'view'

class TrackView < View

  NOTES_OFFSET_X = 15

  attr_accessor :channel

  def initialize(app, parent, layout = {})
    super(parent, layout)
    @app = app
    @app.add_observer(self)

    @offset_step = 0
    @offset_note = app.editor.noteno - height + 1
    @channel = 0
    @active = false

    @context = parent
  end

  def col_step
    @context.col_step
  end
  
  def notes_width
    @context.notes_width
  end

  def offset_step
    @context.offset_step
  end
  
  def on_render
    clear

    render_frame
    update_viewport if @active
    render_keys
    render_notes
    render_cursor if @active
  end

  def render_frame
    (0...height).each do |j|
      if 0 == j
        setpos(j, 0) 
        addstr("CH#{@channel}")
      end
      setpos(j, 4)
      addstr('|')
      setpos(j, 13)
      addstr('|')
    end
  end

  def render_keys
    (0...height).each do |j|
      setpos(height - j - 1, 5)
      addstr(sprintf("%03d:%s", @offset_note + j, Note::LABELS[@offset_note + j]))
    end
  end

  def update_viewport
    if @offset_note > @app.editor.noteno
      @offset_note = @app.editor.noteno
    elsif @app.editor.noteno > @offset_note + height - 1
      @offset_note += @app.editor.noteno - (@offset_note + height - 1)
    end
  end

  def render_notes
    first_pos = @app.song.step2position(offset_step)
    end_step = offset_step + col_step * notes_width

    lines = []
    (0...height).each { |j| lines[j] = ' ' * notes_width }
    (0...height).each do |j|
      measure = first_pos.measure
      measure += 1 unless 0 == first_pos.beat && 0 == first_pos.tick
      step = @app.song.measure2step(measure)
      while step <= end_step
        index = (step - offset_step) / col_step
        lines[j][index] = '.' if 0 <= index && index < notes_width
        measure += 1
        step = @app.song.measure2step(measure)
      end
    end

    notes = @app.song.notes_by_range(offset_step, end_step, @channel, true)
    half = col_step / 2

    notes.each do |n|
      note_index = n.noteno - @offset_note
      next unless 0 <= note_index && note_index < height
      from = (n.step + half - offset_step) / col_step
      to = (n.end_step + half - offset_step) / col_step
      (from == to ? (from..to) : (from...to)).each do |i|
        lines[note_index][i] = i == from ? 'x' : '-' if 0 <= i && i < notes_width
      end
    end

    (0...height).each do |j|
      setpos(height - j - 1, NOTES_OFFSET_X)
      addstr(lines[j])
    end
  end

  def render_cursor
    x = (@app.editor.step - offset_step) / col_step
    y = height - 1 - (@app.editor.noteno - @offset_note)
    setpos(y, NOTES_OFFSET_X + x)
    color(Color::WHITE_RED)
    bold
    addch(inch)
    attroff
  end

  def update(app, type, event, *args)
    case type
    when Application::Event::Type::Editor
    end
  end

  def change_channel(channel)
    @channel = channel
  end

  def activate
    @active = true
    self
  end

  def deactivate
    @active = false
    self
  end
end

