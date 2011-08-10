require 'ansi/logger'

module Veewee
  module Logger
    def logger
      if @logger.nil?
        @logger=ANSI::Logger.new(STDOUT)

        # We silence the logger
        @logger.formatter do |severity, timestamp, progname, msg|
          ""
        end
      end
      return @logger
    end

    # This allows you set the logger manually
    def logger=(thelogger)
      @logger=thelogger
    end

    # INFO, DEBUG, ERROR
    def log_level=(level)
        @logger.level=Object.const_get('ANSI').const_get('Logger').const_get(level.upcase) if @logger
    end

    def enable_ansi
      @logger.ansicolor=true if @logger
    end

    def disable_ansi
      @logger.ansicolor=true if @logger
    end

  end
end
