require 'fileutils'

$root_dir = File.dirname(__FILE__)
$work_dir = File.expand_path("~/.namidi")

FileUtils.mkdir_p($work_dir, mode: 0755) unless Dir.exists? $work_dir
["key_mapping.yml", "settings.yml", "instruments.yml"].each do |file|
  FileUtils.copy("#{$root_dir}/config/#{file}", "#{$work_dir}/#{file}") unless File.exists? "#{$work_dir}/#{file}"
end

Dir[$root_dir + '/app/*'].each { |dir| $:.unshift dir }
Dir[$root_dir + '/app/**/*.rb'].each { |file| require file }

ApplicationController.new.run.destroy
