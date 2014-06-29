require 'curses'
require 'view'

class Screen < View

  def initialize
    Curses.init_screen
    Curses.cbreak
    Curses.noecho
    Curses.raw
    Curses.curs_set(0)
    Curses.start_color
    Curses.init_pair Color::WHITE_BLACK, Curses::COLOR_WHITE, Curses::COLOR_BLACK
    Curses.init_pair Color::WHITE_RED,   Curses::COLOR_WHITE, Curses::COLOR_RED
    Curses.init_pair Color::WHITE_BLUE,  Curses::COLOR_WHITE, Curses::COLOR_BLUE

    @window = Curses.stdscr
    @window.keypad(true)
    @subviews = []
    @visible = true
  end

  def destroy
    super
    Curses.close_screen
  end
end
