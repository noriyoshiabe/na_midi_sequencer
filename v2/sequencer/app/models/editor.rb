require 'observer'

class Editor
  include Observable

  def initialize(song)
    @song = song
  end
end
