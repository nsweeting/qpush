module QPush
  module Server
    # The Worker manages our workers - Queue, Delay, and Perform. Each of these
    # workers is alloted a number of threads. Each worker object maintains
    # control of these threads through the aptly named start and shutdown
    # methods.
    #
    class Worker
      include ObjectValidator::Validate

      attr_accessor :perform_threads, :queue_threads, :delay_threads, :id

      def initialize(options = {})
        options.each { |key, value| send("#{key}=", value) }
        @pid = Process.pid
        @workers = []
        @threads = []
        at_exit { shutdown }
      end

      # Starts our new worker.
      #
      def start
        validate!
        start_message
        build_threads
        start_threads
      end

      # Shutsdown our worker as well as its threads.
      #
      def shutdown
        shutdown_message
        @workers.each(&:shutdown)
        @threads.each(&:exit)
      end

      private

      # Forks the worker and creates the actual threads (@_threads_real) for
      # our Queue and Retry objects. We then start them and join them to the
      # main process.
      #
      def start_threads
        @workers.each do |worker|
          @threads << Thread.new { worker.start }
        end
        @threads.map(&:join)
      end

      # Instantiates our Queue, Perform, and Delay objects based on the number
      # of threads specified for each process type. We store these objects as
      # an array in @threads.
      #
      def build_threads
        @perform_threads.times { @workers << Perform.new }
        @queue_threads.times { @workers << Queue.new }
        @delay_threads.times { @workers << Delay.new }
      end

      # Information about the start process
      #
      def start_message
        Server.log.info("* Worker #{@id} started, pid: #{@pid}")
      end

      # Information about the shutdown process
      #
      def shutdown_message
        Server.log.info("* Worker #{@id} shutdown, pid: #{@pid}")
      end

      # Validates our data before starting the worker.
      #
      def validate!
        return if valid?
        fail ServerError, errors.full_messages.join(' ')
      end
    end

    # The WorkerValidator ensures the data for our worker is valid before
    # attempting to start it.
    #
    class WorkerValidator
      include ObjectValidator::Validator

      validates :perform_threads, type: Integer, greater_than: 0
      validates :queue_threads, type: Integer, greater_than: 0
      validates :delay_threads, type: Integer, greater_than: 0
    end
  end
end
