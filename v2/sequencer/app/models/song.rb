require 'observer'

class Song
  include Observable

  TIME_BASE = 480
  MEASURE_MAX = 100

  attr_accessor :measures
  attr_accessor :notes

  def initialize
    @measures = []
    @notes = []
    start = 0
    prev_m = nil
    MEASURE_MAX.times do |i|
      step = prev_m ? prev_m.next_step : 0
      time = prev_m ? prev_m.next_time : 0.0
      m = Measure.new(i, step, time)
      @measures << m
      prev_m = m
    end
  end

  def time2step(time)
    m = @measures.select { |m| m.time <= time && time < m.next_time }.first
    m ? m.time2step(time) : false
  end

  def step2time(step)
    m = @measures.select { |m| m.step <= step && step < m.next_step }.first
    m ? m.step2time(step) : false
  end

  def measure2step(measure_no)
    @measures[measure_no].step
  end

  def step2position(step)
    m = @measures.select { |m| m.step <= step && step < m.next_step }.first
    delta = step - m.step
    Position.new(m.index, delta / TIME_BASE, delta % TIME_BASE)
  end

  def set_tempo(index, tempo)
    prev = @measures[index]
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
    prev = @measures[index]
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
