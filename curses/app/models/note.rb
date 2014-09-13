class Note
  attr_accessor :step
  attr_accessor :channel
  attr_accessor :noteno
  attr_accessor :velocity
  attr_accessor :gatetime

  def initialize(step, channel, noteno, velocity, gatetime)
    @step = step
    @channel = channel
    @noteno = noteno
    @velocity = velocity
    @gatetime = gatetime
  end

  def end_step
    @step + @gatetime
  end

  def index
    ((@step / Song::NOTE_INDEX_BASE)..(end_step / Song::NOTE_INDEX_BASE)).to_a
  end

  def to_s
    sprintf("step=%d channel=%d noteno=%d velocity=%d gatetime=%d", @step, @channel, @noteno, @velocity, @gatetime)
  end

  LABELS = [
    'C-2', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'C-1', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'C0' , 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'C1',  'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'C2',  'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'C3',  'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'C4',  'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'C5',  'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'C6',  'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'C7',  'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'C8',  'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'C9',  'C#', 'D', 'D#', 'E', 'F', 'F#', 'G', 'G#', 'A', 'A#', 'B',
    'C10', 'C#', 'D', 'D#', 'E', 'F', 'F#', 'G',
  ]

end
