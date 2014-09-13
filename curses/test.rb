$root_dir = File.dirname(__FILE__)

Dir[$root_dir + '/app/*'].each { |dir| $:.unshift dir }
Dir[$root_dir + '/app/**/*.rb'].each { |file| require file }

require $root_dir + '/test/test_helper'

@app = Application.new
@screen = Screen.new
eval(File.open(ARGV[0]).read)
