require 'yaml'

class Instruments

  def self.load_settings(midi_client)
    instruments = YAML.load_file("#{$work_dir}/instruments.yml")
    settings = YAML.load_file("#{$work_dir}/settings.yml")["instruments"] || {}
    (0..15).each do |channel|
      name = settings["ch_#{channel}"]
      if name
        instrument = instruments[name]
        if instrument
          midi_client.program_change(channel, instrument[0], instrument[1], instrument[2])
        end
      end
    end
  end

end
