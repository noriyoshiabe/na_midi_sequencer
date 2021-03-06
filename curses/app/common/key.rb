require 'curses'

module Key
  KEY_MOUSE     = Curses::KEY_MOUSE
  KEY_MIN       = Curses::KEY_MIN
  KEY_BREAK     = Curses::KEY_BREAK
  KEY_DOWN      = Curses::KEY_DOWN
  KEY_UP        = Curses::KEY_UP
  KEY_LEFT      = Curses::KEY_LEFT
  KEY_RIGHT     = Curses::KEY_RIGHT
  KEY_HOME      = Curses::KEY_HOME
  KEY_BACKSPACE = Curses::KEY_BACKSPACE
  KEY_F0        = Curses::KEY_F0
  KEY_F1        = Curses::KEY_F1
  KEY_F2        = Curses::KEY_F2
  KEY_F3        = Curses::KEY_F3
  KEY_F4        = Curses::KEY_F4
  KEY_F5        = Curses::KEY_F5
  KEY_F6        = Curses::KEY_F6
  KEY_F7        = Curses::KEY_F7
  KEY_F8        = Curses::KEY_F8
  KEY_F9        = Curses::KEY_F9
  KEY_F10       = Curses::KEY_F10
  KEY_F11       = Curses::KEY_F11
  KEY_F12       = Curses::KEY_F12
  KEY_F13       = Curses::KEY_F13
  KEY_F14       = Curses::KEY_F14
  KEY_F15       = Curses::KEY_F15
  KEY_F16       = Curses::KEY_F16
  KEY_F17       = Curses::KEY_F17
  KEY_F18       = Curses::KEY_F18
  KEY_F19       = Curses::KEY_F19
  KEY_F20       = Curses::KEY_F20
  KEY_F21       = Curses::KEY_F21
  KEY_F22       = Curses::KEY_F22
  KEY_F23       = Curses::KEY_F23
  KEY_F24       = Curses::KEY_F24
  KEY_F25       = Curses::KEY_F25
  KEY_F26       = Curses::KEY_F26
  KEY_F27       = Curses::KEY_F27
  KEY_F28       = Curses::KEY_F28
  KEY_F29       = Curses::KEY_F29
  KEY_F30       = Curses::KEY_F30
  KEY_F31       = Curses::KEY_F31
  KEY_F32       = Curses::KEY_F32
  KEY_F33       = Curses::KEY_F33
  KEY_F34       = Curses::KEY_F34
  KEY_F35       = Curses::KEY_F35
  KEY_F36       = Curses::KEY_F36
  KEY_F37       = Curses::KEY_F37
  KEY_F38       = Curses::KEY_F38
  KEY_F39       = Curses::KEY_F39
  KEY_F40       = Curses::KEY_F40
  KEY_F41       = Curses::KEY_F41
  KEY_F42       = Curses::KEY_F42
  KEY_F43       = Curses::KEY_F43
  KEY_F44       = Curses::KEY_F44
  KEY_F45       = Curses::KEY_F45
  KEY_F46       = Curses::KEY_F46
  KEY_F47       = Curses::KEY_F47
  KEY_F48       = Curses::KEY_F48
  KEY_F49       = Curses::KEY_F49
  KEY_F50       = Curses::KEY_F50
  KEY_F51       = Curses::KEY_F51
  KEY_F52       = Curses::KEY_F52
  KEY_F53       = Curses::KEY_F53
  KEY_F54       = Curses::KEY_F54
  KEY_F55       = Curses::KEY_F55
  KEY_F56       = Curses::KEY_F56
  KEY_F57       = Curses::KEY_F57
  KEY_F58       = Curses::KEY_F58
  KEY_F59       = Curses::KEY_F59
  KEY_F60       = Curses::KEY_F60
  KEY_F61       = Curses::KEY_F61
  KEY_F62       = Curses::KEY_F62
  KEY_F63       = Curses::KEY_F63
  KEY_DL        = Curses::KEY_DL
  KEY_IL        = Curses::KEY_IL
  KEY_DC        = Curses::KEY_DC
  KEY_IC        = Curses::KEY_IC
  KEY_EIC       = Curses::KEY_EIC
  KEY_CLEAR     = Curses::KEY_CLEAR
  KEY_EOS       = Curses::KEY_EOS
  KEY_EOL       = Curses::KEY_EOL
  KEY_SF        = Curses::KEY_SF
  KEY_SR        = Curses::KEY_SR
  KEY_NPAGE     = Curses::KEY_NPAGE
  KEY_PPAGE     = Curses::KEY_PPAGE
  KEY_STAB      = Curses::KEY_STAB
  KEY_CTAB      = Curses::KEY_CTAB
  KEY_CATAB     = Curses::KEY_CATAB
  KEY_ENTER     = Curses::KEY_ENTER
  KEY_SRESET    = Curses::KEY_SRESET
  KEY_RESET     = Curses::KEY_RESET
  KEY_PRINT     = Curses::KEY_PRINT
  KEY_LL        = Curses::KEY_LL
  KEY_A1        = Curses::KEY_A1
  KEY_A3        = Curses::KEY_A3
  KEY_B2        = Curses::KEY_B2
  KEY_C1        = Curses::KEY_C1
  KEY_C3        = Curses::KEY_C3
  KEY_BTAB      = Curses::KEY_BTAB
  KEY_BEG       = Curses::KEY_BEG
  KEY_CANCEL    = Curses::KEY_CANCEL
  KEY_CLOSE     = Curses::KEY_CLOSE
  KEY_COMMAND   = Curses::KEY_COMMAND
  KEY_COPY      = Curses::KEY_COPY
  KEY_CREATE    = Curses::KEY_CREATE
  KEY_END       = Curses::KEY_END
  KEY_EXIT      = Curses::KEY_EXIT
  KEY_FIND      = Curses::KEY_FIND
  KEY_HELP      = Curses::KEY_HELP
  KEY_MARK      = Curses::KEY_MARK
  KEY_MESSAGE   = Curses::KEY_MESSAGE
  KEY_MOVE      = Curses::KEY_MOVE
  KEY_NEXT      = Curses::KEY_NEXT
  KEY_OPEN      = Curses::KEY_OPEN
  KEY_OPTIONS   = Curses::KEY_OPTIONS
  KEY_PREVIOUS  = Curses::KEY_PREVIOUS
  KEY_REDO      = Curses::KEY_REDO
  KEY_REFERENCE = Curses::KEY_REFERENCE
  KEY_REFRESH   = Curses::KEY_REFRESH
  KEY_REPLACE   = Curses::KEY_REPLACE
  KEY_RESTART   = Curses::KEY_RESTART
  KEY_RESUME    = Curses::KEY_RESUME
  KEY_SAVE      = Curses::KEY_SAVE
  KEY_SBEG      = Curses::KEY_SBEG
  KEY_SCANCEL   = Curses::KEY_SCANCEL
  KEY_SCOMMAND  = Curses::KEY_SCOMMAND
  KEY_SCOPY     = Curses::KEY_SCOPY
  KEY_SCREATE   = Curses::KEY_SCREATE
  KEY_SDC       = Curses::KEY_SDC
  KEY_SDL       = Curses::KEY_SDL
  KEY_SELECT    = Curses::KEY_SELECT
  KEY_SEND      = Curses::KEY_SEND
  KEY_SEOL      = Curses::KEY_SEOL
  KEY_SEXIT     = Curses::KEY_SEXIT
  KEY_SFIND     = Curses::KEY_SFIND
  KEY_SHELP     = Curses::KEY_SHELP
  KEY_SHOME     = Curses::KEY_SHOME
  KEY_SIC       = Curses::KEY_SIC
  KEY_SLEFT     = Curses::KEY_SLEFT
  KEY_SMESSAGE  = Curses::KEY_SMESSAGE
  KEY_SMOVE     = Curses::KEY_SMOVE
  KEY_SNEXT     = Curses::KEY_SNEXT
  KEY_SOPTIONS  = Curses::KEY_SOPTIONS
  KEY_SPREVIOUS = Curses::KEY_SPREVIOUS
  KEY_SPRINT    = Curses::KEY_SPRINT
  KEY_SREDO     = Curses::KEY_SREDO
  KEY_SREPLACE  = Curses::KEY_SREPLACE
  KEY_SRIGHT    = Curses::KEY_SRIGHT
  KEY_SRSUME    = Curses::KEY_SRSUME
  KEY_SSAVE     = Curses::KEY_SSAVE
  KEY_SSUSPEND  = Curses::KEY_SSUSPEND
  KEY_SUNDO     = Curses::KEY_SUNDO
  KEY_SUSPEND   = Curses::KEY_SUSPEND
  KEY_UNDO      = Curses::KEY_UNDO
  KEY_RESIZE    = Curses::KEY_RESIZE
  KEY_MAX       = Curses::KEY_MAX
  KEY_CTRL_A    = Curses::KEY_CTRL_A
  KEY_CTRL_B    = Curses::KEY_CTRL_B
  KEY_CTRL_C    = Curses::KEY_CTRL_C
  KEY_CTRL_D    = Curses::KEY_CTRL_D
  KEY_CTRL_E    = Curses::KEY_CTRL_E
  KEY_CTRL_F    = Curses::KEY_CTRL_F
  KEY_CTRL_G    = Curses::KEY_CTRL_G
  KEY_CTRL_H    = Curses::KEY_CTRL_H
  KEY_CTRL_I    = Curses::KEY_CTRL_I
  KEY_CTRL_J    = Curses::KEY_CTRL_J
  KEY_CTRL_K    = Curses::KEY_CTRL_K
  KEY_CTRL_L    = Curses::KEY_CTRL_L
  KEY_CTRL_M    = Curses::KEY_CTRL_M
  KEY_CTRL_N    = Curses::KEY_CTRL_N
  KEY_CTRL_O    = Curses::KEY_CTRL_O
  KEY_CTRL_P    = Curses::KEY_CTRL_P
  KEY_CTRL_Q    = Curses::KEY_CTRL_Q
  KEY_CTRL_R    = Curses::KEY_CTRL_R
  KEY_CTRL_S    = Curses::KEY_CTRL_S
  KEY_CTRL_T    = Curses::KEY_CTRL_T
  KEY_CTRL_U    = Curses::KEY_CTRL_U
  KEY_CTRL_V    = Curses::KEY_CTRL_V
  KEY_CTRL_W    = Curses::KEY_CTRL_W
  KEY_CTRL_X    = Curses::KEY_CTRL_X
  KEY_CTRL_Y    = Curses::KEY_CTRL_Y
  KEY_CTRL_Z    = Curses::KEY_CTRL_Z

  def self.name(key)
    c = constants.find{ |name|
      /^KEY/ =~ name && const_get(name) == key
    }
    c ? c.to_s : key.to_s
  end
end
