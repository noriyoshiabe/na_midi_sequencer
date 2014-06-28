require 'observer'

class Application
  include Observable

  attr_accessor :song
  attr_accessor :editor
  attr_accessor :player

  def initialize(*args)
    @song = Song.new
    @editor = Editor.new(song)
    @player = Player.new

    @song.add_observer(self)
    @editor.add_observer(self)
    @player.add_observer(self)
  end

  def update
  end
end
