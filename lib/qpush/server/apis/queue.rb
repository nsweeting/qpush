module QPush
  module Server
    module Apis
      class Queue < Base
        def initialize(job)
          @job = job
        end

        def call
          queue_job
        end

        private

        def queue_job
          QPush.redis.with do |conn|
            conn.hincrby(QPush.keys.stats, 'queued', 1)
            conn.lpush(QPush.keys.queue, @job.to_json)
          end
        end
      end
    end
  end
end
