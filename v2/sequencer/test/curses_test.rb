#!/usr/local/bin/ruby
# rain for a curses test

require "curses"
include Curses

def onsig(sig)
  close_screen
  exit sig
end

Signal.trap('SIGINT', proc { |sig| onsig(sig) })

screen = init_screen
refresh

Curses.start_color
win = Window.new(20,10,0,0)
win.setpos(0, 0)
win.bkgd '.'
# win.color_set(COLOR_RED)
win << '====='
win.refresh

getch
win.close
close_screen

=begin
def ranf
  rand(32767).to_f / 32767
end

Signal.trap('SIGINT', proc { |sig| onsig(sig) })
# main #
#for i in %w[HUP INT QUIT TERM]
#  if trap(i, "SIG_IGN") != 0 then  # 0 for SIG_IGN
#    trap(i) {|sig| onsig(sig) }
#  end
#end

init_screen
nl
noecho
srand

xpos = {}
ypos = {}
r = lines - 4
c = cols - 4
for i in 0 .. 4
  xpos[i] = (c * ranf).to_i + 2
  ypos[i] = (r * ranf).to_i + 2
end

i = 0
while TRUE
  x = (c * ranf).to_i + 2
  y = (r * ranf).to_i + 2

  setpos(y, x); addstr(".")

  setpos(ypos[i], xpos[i]); addstr("o")

  i = if i == 0 then 4 else i - 1 end
  setpos(ypos[i], xpos[i]); addstr("O")

  i = if i == 0 then 4 else i - 1 end
  setpos(ypos[i] - 1, xpos[i]);      addstr("-")
  setpos(ypos[i],     xpos[i] - 1); addstr("|.|")
  setpos(ypos[i] + 1, xpos[i]);      addstr("-")

  i = if i == 0 then 4 else i - 1 end
  setpos(ypos[i] - 2, xpos[i]);       addstr("-")
  setpos(ypos[i] - 1, xpos[i] - 1);  addstr("/ \\")
  setpos(ypos[i],     xpos[i] - 2); addstr("| O |")
  setpos(ypos[i] + 1, xpos[i] - 1); addstr("\\ /")
  setpos(ypos[i] + 2, xpos[i]);       addstr("-")

  i = if i == 0 then 4 else i - 1 end
  setpos(ypos[i] - 2, xpos[i]);       addstr(" ")
  setpos(ypos[i] - 1, xpos[i] - 1);  addstr("   ")
  setpos(ypos[i],     xpos[i] - 2); addstr("     ")
  setpos(ypos[i] + 1, xpos[i] - 1);  addstr("   ")
  setpos(ypos[i] + 2, xpos[i]);       addstr(" ")

  xpos[i] = x
  ypos[i] = y
  refresh
  sleep(0.5)
end

# end of main
=end


=begin
require "curses"
require "highline"


include Curses

init_screen
setpos(0, 0)

line = ''

num = HighLine::SystemExtensions.terminal_size[0]
num.times do
  line << '='
end

addstr(line)
refresh
win = Window.new(5, 5, 2, 0)
#win.box(?|,?-,?*)
#win.setpos(win.maxy / 2, win.maxx / 2 - (s.length / 2))
win.setpos(0,0)
win.addstr(line)
win.refresh

getch

win.close
close_screen
=end
