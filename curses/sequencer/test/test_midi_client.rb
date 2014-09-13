$:.unshift File.dirname(__FILE__) + '/../lib'
$:.unshift File.dirname(__FILE__) + '/../ext'

require 'midi_client'

c = MidiClient.new
c.send([0x99, 0x26, 0x7f].pack('C*'))
c.close
