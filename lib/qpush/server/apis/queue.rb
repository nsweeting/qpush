module QPush
  module Server
    module Apis
      class Queue < Base
        def call
          queue_job
        end

        private

        def queue_job
          Server.redis do |conn|
            conn.hincrby(Server.keys.stats, 'queued', 1)
            conn.lpush(Server.keys.queue, @job.to_json)
          end
        end
      end
    end
  end
end
