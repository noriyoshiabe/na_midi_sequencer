require 'socket'

class MidiClient
  SOCK_FILE	= '/tmp/namidi.sock'

  def self.note_on(note)
    UNIXSocket.open(SOCK_FILE) do |s|
      s.write([0x90 | note.channel, note.noteno, note.velocity].pack('C*'))
    end
  end

  def self.note_off(note)
    UNIXSocket.open(SOCK_FILE) do |s|
      s.write([0x80 | note.channel, note.noteno, 0].pack('C*'))
    end
  end

  def self.program_change(channel, msb, lsb, number)
    UNIXSocket.open(SOCK_FILE) do |s|
      s.write([0xB0 | channel, 0x00, msb].pack('C*'))
    end
    UNIXSocket.open(SOCK_FILE) do |s|
      s.write([0xB0 | channel, 0x20, lsb].pack('C*'))
    end
    UNIXSocket.open(SOCK_FILE) do |s|
      s.write([0xC0 | channel, number].pack('C*'))
    end
  end
end
