module QPush
  module Server
    module Apis
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
          QPush.redis.with do |conn|
            conn.hincrby(QPush.keys.stats, @stat, 1)
            conn.zadd(QPush.keys.delay, @time, @job.to_json)
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
