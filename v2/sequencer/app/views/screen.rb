require 'curses'
require 'view'

class Screen < View

  def initialize
    Curses.init_screen
    Curses.cbreak
    Curses.noecho
    Curses.raw
    @window = Curses.stdscr
    @subviews = []
    @visible = true
  end

  def destroy
    super
    Curses.close_screen
  end
end
