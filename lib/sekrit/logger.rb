require 'logger'

class Object
  def self.logger
    if @logger.nil?
      @logger = Logger.new(STDOUT)
      @logger.level = Logger::DEBUG
    end

    @logger
  end

  def log
    Object.logger
  end
end
