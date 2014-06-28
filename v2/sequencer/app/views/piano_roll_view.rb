require 'view'

class PianoRollView < View

  NOTES_OFFSET_X = 15

  def initialize(app, parent, layout = {})
    super(parent, layout)
    @app = app
    @app.add_observer(self)

    @col_step = 120
    @offset_measure = 0
    @offset_note = 30
    @channel = 9
  end
  
  def on_render
    render_frame
    render_keys
    render_notes
  end

  def render_frame
    (0...height).each do |j|
      if 0 == j
        window.setpos(j, 0) 
        window.addstr("CH#{@channel}")
      end
      window.setpos(j, 4)
      window.addstr('|')
      window.setpos(j, 13)
      window.addstr('|')
    end
  end

  def render_keys
    (0...height).each do |j|
      window.setpos(height - j - 1, 5)
      window.addstr(sprintf("%03d:%s", @offset_note + j, Note::LABELS[@offset_note + j]))
    end
  end

  def render_notes
    notes_width = width - NOTES_OFFSET_X

    first_step = @app.song.measure2step(@offset_measure)
    end_step = first_step + @col_step * notes_width

    lines = []
    (0...height).each { |j| lines[j] = ' ' * notes_width }
    (0...height).each do |j|
      step = first_step
      measure = @offset_measure
      while step <= end_step
        index = (step - first_step) / @col_step
        lines[j][index] = '.'
        measure += 1
        step = @app.song.measure2step(measure)
      end
    end

    notes = @app.song.notes_by_range(first_step, end_step, @channel, true)
    half = @col_step / 2

    notes.each do |n|
      note_index = n.noteno - @offset_note
      next unless 0 <= note_index && note_index < height
      from = (n.step + half - first_step) / @col_step
      to = (n.end_step + half - first_step) / @col_step
      (from...to).each do |i|
        lines[note_index][i] = i == from ? 'x' : '-'
      end
    end

    (0...height).each do |j|
      window.setpos(height - j - 1, NOTES_OFFSET_X)
      window.addstr(lines[j])
    end
  end

  def update(app, type, event, *args)
  end
end

