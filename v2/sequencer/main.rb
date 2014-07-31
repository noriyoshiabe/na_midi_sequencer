$root_dir = File.dirname(__FILE__)
$work_dir = File.expand_path("~/.namidi")

Dir[$root_dir + '/app/*'].each { |dir| $:.unshift dir }
Dir[$root_dir + '/app/**/*.rb'].each { |file| require file }

ApplicationController.new.run.destroy
