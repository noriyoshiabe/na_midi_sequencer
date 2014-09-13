require 'yaml'

class TestHelper
  def self.serialize(obj, fixture_name)
    File.open("#{$root_dir}/test/fixtures/#{fixture_name}.yml", 'w') do |file|
      file.puts YAML::dump(obj)
    end
  end

  def self.deserialize(fixture_name)
    ret = nil
    File.open("#{$root_dir}/test/fixtures/#{fixture_name}.yml", 'r') do |file|
      ret = YAML::load(file)
    end
    ret
  end
end
