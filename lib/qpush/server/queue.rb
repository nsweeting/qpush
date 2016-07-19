module QPush
  module Server
    # The Queue worker takes any jobs that are queued into our Redis server,
    # and moves them to the appropriate list within Redis.
    # It will perform a 'blocking pop' on our queue list until one is added.
    #
    class Queue
      def initialize
        @done = false
      end

      # Starts our queue process. This will run until instructed to stop.
      #
      def start
        until @done
          job = retrieve_job
          job.api.setup if job
        end
      end

      # Shutsdown our queue process.
      #
      def shutdown
        @done = true
      end

      private

      # Performs a 'blocking pop' on our redis job list.
      #
      def retrieve_job
        json = QPush.redis.with { |c| c.brpop(QPush.config.queue_namespace) }
        Job.new(JSON.parse(json.last))
      rescue => e
        raise ServerError, e.message
      end
    end
  end
end
