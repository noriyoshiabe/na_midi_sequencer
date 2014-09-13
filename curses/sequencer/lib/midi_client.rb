class MidiClient
  def note_on(note)
    send([0x90 | note.channel, note.noteno, note.velocity].pack('C*'))
  end

  def note_off(note)
    send([0x80 | note.channel, note.noteno, 0].pack('C*'))
  end

  def program_change(channel, msb, lsb, number)
    send([0xB0 | channel, 0x00, msb].pack('C*'))
    send([0xB0 | channel, 0x20, lsb].pack('C*'))
    send([0xC0 | channel, number].pack('C*'))
  end
end

require 'midi_client/midi_client'
