class Note
  attr_accessor :step
  attr_accessor :channel
  attr_accessor :noteno
  attr_accessor :velociy
  attr_accessor :gatetime

  def initialize(step, channel, noteno, velociy, gatetime)
    @step = step
    @channel = channel
    @noteno = noteno
    @velociy = velociy
    @gatetime = gatetime
  end

  def end_step
    @step + @gatetime
  end

  def to_s
    sprintf("step=%d channel=%d noteno=%d velociy=%d gatetime=%d", @step, @channel, @noteno, @velociy, @gatetime)
  end
end
