require 'observer'

class Song
  include Observable

  TIME_BASE = 480
  INITIAL_MEASURE_NUM = 100

  NOTE_INDEX_BASE = TIME_BASE
  MEASURE_TIME_INDEX_BASE = 2
  MEASURE_STEP_INDEX_BASE = TIME_BASE * 4

  attr_accessor :measures
  attr_accessor :notes

  def initialize
    @notes = []
    @note_index = {}
    @measure_time_index = {}
    @measure_step_index = {}
    start = 0
    measure_zero = Measure.new(0, 0, 0.0)
    @measures = [measure_zero]
    index_measure(measure_zero)
    extend_measure(INITIAL_MEASURE_NUM - 1)
  end

  def time2step(time)
    arr = @measure_time_index[time.to_i / MEASURE_TIME_INDEX_BASE]
    if arr
      m = arr.find { |m| m.time <= time && time < m.next_time }
      m ? m.time2step(time) : false
    end
  end

  def step2time(step)
    arr = @measure_step_index[step / MEASURE_STEP_INDEX_BASE]
    if arr
      m = arr.find { |m| m.step <= step && step < m.next_step }
      m ? m.step2time(step) : false
    end
  end

  def measure_at(measure_no)
    extend_measure(measure_no) if @measures.length <= measure_no
    @measures[measure_no]
  end

  def extend_measure(measure_no)
    last = @measures.last
    (measure_no - (@measures.length - 1)).times do
      m = Measure.new(last.index + 1, last.next_step, last.next_time, last.numerator, last.denominator, last.tempo)
      @measures << m
      index_measure(m)
      last = m
    end
  end

  def index_measure(measure)
    measure.time_index.each do |i|
      @measure_time_index[i] ||= []
      @measure_time_index[i] << measure
    end
    measure.step_index.each do |i|
      @measure_step_index[i] ||= []
      @measure_step_index[i] << measure
    end
  end

  def build_measure_index
    @measure_time_index.clear
    @measure_step_index.clear
    @measures.each do |m|
      index_measure(m)
    end
  end

  def rebuild_measures
    prev = nil
    @measures.each_with_index do |m, i|
      m.index = i
      m.step = prev ? prev.next_step : 0
      m.time = prev ? prev.next_time : 0.0
      m.calc_next
      index_measure(m)
      prev = m
    end

    build_measure_index
  end

  def delete_measure(from, length)
    ret = @measures.slice!(from, length)
    rebuild_measures
    ret
  end

  def insert_measure(from, obj)
    if obj.instance_of? Array
      obj.reverse.each do |m|
        @measures.insert(from, m)
      end
    elsif obj.instance_of? Fixnum
      src = @measures[from]
      obj.times.map do
        Measure.new(0, 0, 0, src.numerator, src.denominator, src.tempo)
      end.each do |m|
        @measures.insert(from, m)
      end
    end

    rebuild_measures
    build_note_index
  end

  def measure2step(measure_no)
    measure_at(measure_no).step
  end

  def step2measure(step)
    while @measures.last.next_step <= step
      extend_measure(@measures.last.index + 1)
    end

    @measure_step_index[step / MEASURE_STEP_INDEX_BASE].find { |m| m.step <= step && step < m.next_step }
  end

  def step2position(step)
    m = step2measure(step)
    delta = step - m.step
    Position.new(m.index, delta / TIME_BASE, delta % TIME_BASE)
  end

  def set_tempo(index, tempo)
    prev = measure_at(index)
    return false unless prev
    prev_tempo = prev.tempo
    @measures[index..-1].each_with_index do |m, i|
      if prev_tempo == m.tempo
        m.tempo = tempo
      else
        prev_tempo = -1
      end

      if 0 < i
        m.step = prev.next_step
        m.time = prev.next_time
      end

      m.calc_next
      prev = m
    end

    build_measure_index
  end

  def set_beat(index, numerator, denominator)
    prev = measure_at(index)
    return false unless prev
    prev_numerator = prev.numerator
    prev_denominator = prev.denominator
    @measures[index..-1].each_with_index do |m, i|
      if prev_numerator == m.numerator && prev_denominator == m.denominator
        m.numerator = numerator
        m.denominator = denominator
      else
        prev_numerator = prev_denominator = -1
      end

      if 0 < i
        m.step = prev.next_step
        m.time = prev.next_time
      end

      m.calc_next
      prev = m
    end

    build_measure_index
  end

  def set_marker(index, text)
    measure = measure_at(index)
    return false unless measure
    measure.marker = text
  end

  def build_note_index
    @note_index.clear
    @notes.each do |note|
      note.index.each do |i|
        @note_index[i] ||= []
        @note_index[i] << note
      end
    end
  end

  def add_note(note)
    @notes << note
  end

  def remove_note(note)
    @notes.delete(note)
  end

  def notes_from(from, channel = nil)
    @notes.select do |n|
      from <= n.step
    end
  end

  def notes_by_range(from, to, channel = nil, cross = false)
    ret = []

    if cross
      ((from / NOTE_INDEX_BASE)..(to / NOTE_INDEX_BASE)).each do |i|
        arr = @note_index[i]
        if arr
          ret += arr.select do |n|
            from <= n.end_step && n.step < to && (channel.nil? || n.channel == channel)
          end
        end
      end
    else
      ((from / NOTE_INDEX_BASE)..(to / NOTE_INDEX_BASE)).each do |i|
        arr = @note_index[i]
        if arr
          ret += arr.select do |n|
            from <= n.step && n.step < to && (channel.nil? || n.channel == channel)
          end
        end
      end
    end

    ret.uniq
  end

  def has_tempo_change(measure_no)
    0 == measure_no || measure_at(measure_no).tempo != measure_at(measure_no - 1).tempo
  end

  def has_beat_change(measure_no)
    0 == measure_no ||
      measure_at(measure_no).numerator != measure_at(measure_no - 1).numerator ||
      measure_at(measure_no).denominator != measure_at(measure_no - 1).denominator
  end

  def has_marker(measure_no)
    !measure_at(measure_no).marker.nil?
  end

  class Measure
    attr_accessor :index
    attr_accessor :step
    attr_accessor :time
    attr_accessor :numerator
    attr_accessor :denominator
    attr_accessor :tempo
    attr_accessor :marker
    attr_accessor :next_step
    attr_accessor :next_time

    def initialize(index, step, time, numerator = 4, denominator = 4, tempo = 120.0, marker = nil)
      @index = index
      @step = step
      @time = time
      @numerator = numerator
      @denominator = denominator
      @tempo = tempo
      @marker = marker

      calc_next
    end

    def calc_next
      @next_step = @step + step_length
      @next_time = @time + time_length
    end

    def step_length
      TIME_BASE * 4 / @denominator * @numerator
    end

    def time_length
      time_per_beat / TIME_BASE * step_length
    end

    def time_per_beat
      60.0 / @tempo
    end

    def time_per_tick
      time_per_beat / TIME_BASE
    end

    def time2step(time)
      @step + ((time - @time) / time_per_tick).to_i
    end

    def step2time(step)
      @time + (step - @step) * time_per_tick
    end

    def to_s
      sprintf("index=%d step=%d time=%f numerator=%d denominator=%d tempo=%f next_step=%d next_time=%f", @index, @step, @time, @numerator, @denominator, @tempo, @next_step, @next_time)
    end

    def time_index
      ((@time.to_i / MEASURE_TIME_INDEX_BASE)..(@next_time.to_i / MEASURE_TIME_INDEX_BASE))
    end

    def step_index
      ((@step / MEASURE_STEP_INDEX_BASE)..(@next_step / MEASURE_STEP_INDEX_BASE))
    end
  end

  class Position
    attr_accessor :measure
    attr_accessor :beat
    attr_accessor :tick
    def initialize(measure, beat, tick)
      @measure = measure
      @beat = beat
      @tick = tick
    end
  end
end
