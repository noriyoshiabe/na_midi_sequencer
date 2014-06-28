require 'logger'

$logger = Logger.new($root_dir + '/log/debug.log')

def p(content)
  $logger.debug(content)
end

def puts(content)
  $logger.debug(content.to_s)
end

def printf(*args)
  $logger.debug(sprintf(*args))
end
