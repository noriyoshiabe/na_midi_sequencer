require 'logger'

$logger = Logger.new($work_dir + '/namidi.log')

def p(content)
  $logger.debug(content)
end

def puts(content)
  $logger.debug(content.to_s)
end

def printf(*args)
  $logger.debug(sprintf(*args))
end

class Log
  def self.debug(*args)
    $logger.debug(*args)
  end

  def self.info(*args)
    $logger.info(*args)
  end

  def self.warn(*args)
    $logger.warn(*args)
  end

  def self.error(*args)
    $logger.error(*args)
  end

  def self.fatal(*args)
    $logger.fatal(*args)
  end

  def self.unknown(*args)
    $logger.unknown(*args)
  end
end
