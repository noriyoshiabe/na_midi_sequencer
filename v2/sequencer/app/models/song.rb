require 'observer'

class Song
  include Observable

  TIME_BASE = 480
  INITIAL_MEASURE_NUM = 100

  attr_accessor :measures
  attr_accessor :notes

  def initialize
    @notes = []
    start = 0
    @measures = [Measure.new(0, 0, 0.0)]
    extend_measure(INITIAL_MEASURE_NUM - 1)
  end

  def time2step(time)
    m = @measures.find { |m| m.time <= time && time < m.next_time }
    m ? m.time2step(time) : false
  end

  def step2time(step)
    m = @measures.find { |m| m.step <= step && step < m.next_step }
    m ? m.step2time(step) : false
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
      last = m
    end
  end

  def measure2step(measure_no)
    measure_at(measure_no).step
  end

  def step2measure(step)
    @measures.find { |m| m.step <= step && step < m.next_step }
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
  end

  def add_note(note)
    @notes << note
    @notes.sort_by! { |n| [n.step, n.channel, n.noteno] }
  end

  def remove_note(note)
    @notes.delete(note)
  end

  def notes_by_range(from, to, channel = nil, cross = false)
    if cross
      @notes.select do |n|
        from <= n.end_step && n.step < to && (channel.nil? || n.channel == channel)
      end
    else
      @notes.select do |n|
        from <= n.step && n.step < to && (channel.nil? || n.channel == channel)
      end
    end
  end

  def has_tempo_change(measure_no)
    0 == measure_no || measure_at(measure_no).tempo != measure_at(measure_no - 1).tempo
  end

  def has_beat_change(measure_no)
    0 == measure_no ||
      measure_at(measure_no).numerator != measure_at(measure_no - 1).numerator ||
      measure_at(measure_no).denominator != measure_at(measure_no - 1).denominator
  end

  class Measure
    attr_accessor :index
    attr_accessor :step
    attr_accessor :time
    attr_accessor :numerator
    attr_accessor :denominator
    attr_accessor :tempo
    attr_accessor :next_step
    attr_accessor :next_time

    def initialize(index, step, time, numerator = 4, denominator = 4, tempo = 120.0)
      @index = index
      @step = step
      @time = time
      @numerator = numerator
      @denominator = denominator
      @tempo = tempo

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
