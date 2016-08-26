module QPush
  module Server
    # The Manager controls our Worker processes. We use it to instruct each
    # of them to start and shutdown.
    #
    class Manager
      attr_accessor :configs
      attr_reader :forks

      def initialize(configs)
        @configs = configs
        @master = Process.pid
        @forks = []
        at_exit { shutdown }
      end

      # Instantiates new Worker objects, setting them with our options. We
      # follow up by booting each of our Workers. Our Manager is then put to
      # sleep so that our Workers can do their thing.
      #
      def start
        start_messages
        flush_spaces
        create_workers
        Process.wait
      end

      # Shutsdown our Worker processes.
      #
      def shutdown
        unless @forks.empty?
          @forks.each { |w| Process.kill('QUIT', w[:pid].to_i) }
        end
        Process.waitall
        Process.kill('SIGTERM', @master)
      end

      private

      # Create the specified number of workers and starts them
      #
      def create_workers
        @configs.each_with_index do |config, id|
          pid = fork { Worker.new(id, config).start }
          @forks << { id: id, pid: pid }
        end
      end

      # Information about the start process
      #
      def start_messages
        Server.log.info("* Worker count: #{@configs.count}")
      end

      # Removes the list of namespaces used by our server from Redis. This
      # prepares it for the new list that will be created by our workers.
      #
      def flush_spaces
        Server.redis { |c| c.del("#{QPush::Base::KEY}:namespaces") }
      end
    end
  end
end
