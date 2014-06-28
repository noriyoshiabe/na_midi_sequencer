Dir[File.dirname(__FILE__) + '/app/*'].each { |dir| $:.unshift dir }
Dir[File.dirname(__FILE__) + '/app/**/*.rb'].each { |file| require file }

ApplicationController.new.run.destroy
