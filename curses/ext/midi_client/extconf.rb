require "mkmf"
abort "missing CoreMIDI" unless have_header "CoreMIDI/CoreMIDI.h"
CONFIG['LDSHARED'] << " -framework CoreMidi"
create_makefile "midi_client/midi_client"
