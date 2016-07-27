module QPush
  module Server
    module Apis
      class Morgue < Base
        def initialize(job)
          @job = job
        end

        def call
          send_to_morgue
        end

        private

        def send_to_morgue
          QPush.redis.with do |conn|
            conn.hincrby(QPush.keys.stats, 'dead', 1)
            conn.lpush(QPush.keys.morgue, @job.to_json)
          end
        end
      end
    end
  end
end
