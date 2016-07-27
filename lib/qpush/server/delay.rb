module QPush
  module Server
    # The Delay worker requeues any jobs that have been delayed on our Redis
    # server. Delayed jobs are pulled by a 'zrangebyscore', with the score
    # representing the time the job should be performed.
    #
    class Delay
      def initialize
        @done = false
        @conn = nil
      end

      # Starts our delay process. This will run until instructed to stop.
      #
      def start
        until @done
          QPush.redis.with do |conn|
            @conn = conn
            watch_delay { retrieve_delays }
          end
          sleep 2
        end
      end

      # Shutsdown our delay process.
      #
      def shutdown
        @done = true
      end

      private

      # Retrieves delayed jobs based on the time they should be performed.
      # If any are found, begin to update them.
      #
      def retrieve_delays
        delays = @conn.zrangebyscore(QPush.keys.delay, 0, Time.now.to_i)
        delays.any? ? update_delays(delays) : @conn.unwatch
      end

      # Removes jobs that have been retrieved and sets them up to be performed.
      #
      def update_delays(delays)
        @conn.multi do |multi|
          multi.zrem(QPush.keys.delay, delays)
          delays.each { |job| perform_job(job) }
        end
      end

      # Add a delayed job to the appropriate perform list.
      #
      def perform_job(json)
        job = Job.new(JSON.parse(json))
        job.perform
      rescue => e
        raise ServerError, e.message
      end

      # Performs a watch on our delay list
      #
      def watch_delay
        @conn.watch(QPush.keys.delay) do
          yield if block_given?
        end
      end
    end
  end
end
