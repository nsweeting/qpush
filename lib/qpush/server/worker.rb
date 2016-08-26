
module QPush
  module Server
    # The Worker manages our workers - Queue, Delay, Perform and Heartbeat.
    # Each of these workers is alloted a number of threads. Each worker
    # object maintains control of these threads through the aptly named start
    # and shutdown methods.
    #
    class Worker
      extend Forwardable
      include ObjectValidator::Validate

      attr_reader :config, :pid, :id

      def_delegators :@config, :perform_threads, :delay_threads, :queue_threads,
                     :priorities, :base_threads, :namespace

      def initialize(id, config)
        @id = id
        @pid = Process.pid
        @config = config
        @actions = []
        @threads = []
        at_exit { shutdown }
      end

      # Starts our new worker.
      #
      def start
        validate!
        assign_globals
        register_space
        start_message
        build_threads
        start_threads
      end

      # Shutsdown our worker as well as its threads.
      #
      def shutdown
        shutdown_message
        @actions.each(&:shutdown)
        @threads.each(&:exit)
      end

      private

      # Forks the worker and creates the actual threads (@threads) for
      # our Queue and Retry objects. We then start them and join them to the
      # main process.
      #
      def start_threads
        @actions.each do |action|
          @threads << Thread.new { action.start }
        end
        @threads.map(&:join)
      end

      # Instantiates our Queue, Perform, Delay and Heartbeat objects based on
      # the number of threads specified for each process type. We store these
      # objects as an array in @actions.
      #
      def build_threads
        base_threads.each do |thread|
          thread[:count].times do
            @actions << thread[:klass].new
          end
        end
      end

      def base_threads
        [
          { klass: Perform, count: perform_threads },
          { klass: Queue, count: queue_threads },
          { klass: Delay, count: delay_threads },
          { klass: Heartbeat, count: 1 }
        ]
      end

      # Information about the start process
      #
      def start_message
        Server.log.info("* Worker #{@id} started | pid: #{@pid} | namespace: #{namespace}")
      end

      # Information about the shutdown process
      #
      def shutdown_message
        Server.log.info("* Worker #{@id} shutdown | pid: #{@pid}")
      end

      # Validates our data before starting the worker.
      #
      def validate!
        return if valid?
        fail ServerError, errors.full_messages.join(' ')
      end

      def assign_globals
        Server.keys = Server.build_keys(@config.namespace, @config.priorities)
        Server.worker = self
      end

      # Registers our workers namespace on Redis
      #
      def register_space
        Server.redis do |c|
          c.sadd(QPush::Base::KEY + ':namespaces', namespace)
        end
      end
    end

    # The WorkerValidator ensures the data for our worker is
    # valid before attempting to use it.
    #
    class WorkerValidator
      include ObjectValidator::Validator

      validates :config, type: QPush::Server::WorkerConfig
      validates :perform_threads, type: Integer, greater_than: 0
      validates :queue_threads, type: Integer, greater_than: 0
      validates :delay_threads, type: Integer, greater_than: 0
      validates :namespace, type: String
      validates :priorities, type: Integer, greater_than: 4
    end
  end
end
