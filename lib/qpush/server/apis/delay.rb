module QPush
  module Server
    module Apis
      # The Delay API will take a job and add it to the delay sorted set.
      #
      class Delay < Base
        def initialize(job, type)
          @job = job
          @type = type
        end

        def call
          load_type
          delay_job
        end

        private

        def delay_job
          Server.redis do |conn|
            conn.hincrby(Server.keys.stats, @stat, 1)
            conn.zadd(Server.keys.delay, @time, @job.to_json)
          end
        end

        def load_type
          case @type
          when :delay
            @stat = 'delayed'
            @time = @job.delay_until
          when :retry
            @stat = 'retries'
            @time = @job.retry_at
          end
        end
      end
    end
  end
end
