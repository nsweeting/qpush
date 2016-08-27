module QPush
  module Server
    class << self
      attr_accessor :worker

      # A convenience method used to create new WorkerConfig objects for use
      # in our server configuration.
      #
      def build_worker
        worker = WorkerConfig.new
        yield worker
        worker
      end
    end

    # The Worker manages our actions - Queue, Delay, Perform and Heartbeat.
    # Each of these actions is alloted a number of threads. Each action
    # object maintains control of these threads through the aptly named start
    # and shutdown methods.
    #
    class Worker
      attr_reader :config, :pid, :id

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
        assign_globals
        register_space
        start_message
        build_actions
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

      # Assign the globals that are required for our worker to function.
      #
      def assign_globals
        Server.keys = Server.build_keys(@config.namespace, @config.priorities)
        Server.worker = self
      end

      # Registers our workers namespace on Redis
      #
      def register_space
        Server.redis do |c|
          c.sadd("#{QPush::Base::KEY}:namespaces", @config.namespace)
        end
      end

      # Information about the start process
      #
      def start_message
        Server.log.info("* Worker #{@id} started | pid: #{@pid} | namespace: #{@config.namespace}")
      end

      # Instantiates our Queue, Perform, Delay and Heartbeat objects based on
      # the number of threads specified for each action type. We store these
      # objects as an array in @actions.
      #
      def build_actions
        base_actions.each do |action|
          action[:count].times do
            @actions << action[:klass].new
          end
        end
      end

      def base_actions
        [
          { klass: Perform, count: @config.perform_threads },
          { klass: Queue, count: @config.queue_threads },
          { klass: Delay, count: @config.delay_threads },
          { klass: Heartbeat, count: 1 }
        ]
      end

      # Creates threads for each of the action objects, We then start them and
      # join them to the main process.
      #
      def start_threads
        @actions.each do |action|
          @threads << Thread.new { action.start }
        end
        @threads.map(&:join)
      end

      # Information about the shutdown process
      #
      def shutdown_message
        Server.log.info("* Worker #{@id} shutdown | pid: #{@pid}")
      end
    end

    class WorkerConfig
      include ObjectValidator::Validate

      DEFAULTS = {
        namespace: 'default',
        priorities: 5,
        queue_threads: 2,
        perform_threads: 2,
        delay_threads: 1 }.freeze

      attr_accessor :perform_threads, :queue_threads, :delay_threads,
                    :namespace, :priorities

      def initialize(options = {})
        options = DEFAULTS.merge(options)
        options.each { |key, value| send("#{key}=", value) }
      end

      def validate!
        return if valid?
        fail ServerError, errors.full_messages.join(' ')
      end
    end

    class WorkerConfigValidator
      include ObjectValidator::Validator

      validates :namespace, type: String
      validates :priorities, greater_than: 4
      validates :queue_threads, greater_than: 0
      validates :perform_threads, greater_than: 0
      validates :delay_threads, greater_than: 0
    end
  end
end
