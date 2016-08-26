module QPush
  module Server
    class << self
      STDOUT.sync = true

      def log
        @log ||= Log.new
      end
    end

    # The Log is a simple wrapper for the Logger. It outputs log info in a
    # defined manner to the console.
    #
    class Log
      def initialize
        @log = ::Logger.new(STDOUT)
        @log.formatter = proc do |_severity, _datetime, _progname, msg|
          "#{msg}\n"
        end
      end

      # Creates a new info log message.
      #
      def info(msg)
        @log.info("[ \e[32mOK\e[0m ] #{msg}")
      end

      # Creates a new error log message.
      #
      def err(msg, action: :no_exit)
        @log.info("[ \e[31mER\e[0m ] #{msg}")
        exit 1 if action == :exit
      end
    end
  end
end
