module QPush
  module Server
    # Handles the start of the QPush server via command line
    #
    class Launcher
      def initialize(argv)
        @argv = argv
      end

      # Parses commmand line options and starts the Manager object
      #
      def start
        start_message
        setup_options
        boot_manager
      end

      private

      def start_message
        Server.log.info('QPush Server starting!')
        Server.log.info("* Version #{QPush::VERSION}, codename: #{QPush::CODENAME}")
      end

      # Parses the arguments passed through the command line.
      #
      def setup_options
        parser = OptionParser.new do |o|
          o.banner = 'Usage: bundle exec bin/QPush [options]'

          o.on('-c', '--config PATH', 'Load PATH for config file') do |arg|
            load(arg)
            Server.log.info("* Server config:  #{arg}")
          end

          o.on('-h', '--help', 'Prints this help') { puts o && exit }
        end
        parser.parse!(@argv)
      end

      def boot_manager
        manager = Manager.new(QPush.config.manager_options)
        manager.start
      end
    end
  end
end
