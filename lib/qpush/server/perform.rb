module QPush
  module Server
    # The Perform worker runs any jobs that are queued into our Redis server.
    # It will perform a 'blocking pop' on our job list until one is added.
    #
    class Perform
      def initialize
        @done = false
        @lists = QPush.keys.perform_lists
      end

      # Starts our perform process. This will run until instructed to stop.
      #
      def start
        until @done
          job = retrieve_job
          job.execute if job
        end
      end

      # Shutsdown our perform process.
      #
      def shutdown
        @done = true
      end

      private

      # Performs a 'blocking pop' on our redis job list.
      #
      def retrieve_job
        json = QPush.redis.with { |c| c.brpop(@lists) }
        Job.new(JSON.parse(json.last))
      rescue => e
        raise ServerError, e.message
      end
    end
  end
end
