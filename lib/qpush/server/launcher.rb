module QPush
  module Server
    # Handles the start of the QPush server via command line
    #
    class Launcher
      def initialize(argv)
        @argv = argv
      end

      # Provides the main entrypoint for starting a QPush server.
      #
      def start
        start_message
        setup_options
        validate!
        setup_jobs
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
          o.banner = 'Usage: bundle exec qpush-server [options]'

          o.on('-c', '--config PATH', 'Load PATH for config file') do |arg|
            load(arg)
            Server.log.info("* Server config:  #{arg}")
          end

          o.on('-h', '--help', 'Prints this help') { puts o && exit }
        end
        parser.parse!(@argv)
      end

      # Validates our server and worker configuration.
      #
      def validate!
        Server.config.validate!
        Server.config.workers.each { |w| w.validate! }
      end

      # Requires all base jobs as well as user jobs.
      #
      def setup_jobs
        JobLoader.call
      end

      # Boots our manager
      #
      def boot_manager
        manager = Manager.new(Server.config.workers)
        manager.start
      end
    end
  end
end
