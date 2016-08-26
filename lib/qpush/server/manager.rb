module QPush
  module Server
    # The Manager controls our Worker processes. We use it to instruct each
    # of them to start and shutdown.
    #
    class Manager
      include ObjectValidator::Validate

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
        validate!
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

      # Validates our data before starting our Workers. Also instantiates our
      # connection pool by pinging Redis.
      #
      def validate!
        return if valid?
        fail ServerError, errors.full_messages.join(' ')
      end

      # Removes the list of namespaces used by our server from Redis. This
      # prepares it for the new list that will be created by our workers.
      #
      def flush_spaces
        Server.redis { |c| c.del(QPush::Base::KEY + ':namespaces') }
      end
    end

    # The ManagerValidator ensures the data for our manager is valid before
    # attempting to start it.
    #
    class ManagerValidator
      include ObjectValidator::Validator

      validates :redis, with: { proc: proc { Server.redis { |c| c.ping && c.quit } },
                                msg: 'could not be connected with' }
      validates :configs, with: { proc: proc { |m| m.configs.count > 0 },
                                  msg: 'were not defined' }
      validates :configs, with: { proc: proc { |m| m.configs.all? { |x| x.is_a?(WorkerConfig) } },
                                  msg: 'are not valid WorkerConfig objects' }
    end
  end
end
