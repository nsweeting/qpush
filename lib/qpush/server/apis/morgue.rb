module QPush
  module Server
    module Apis
      class Morgue < Base
        def call
          send_to_morgue
        end

        private

        def send_to_morgue
          Server.redis do |conn|
            conn.hincrby(Server.keys.stats, 'dead', 1)
            conn.lpush(Server.keys.morgue, @job.to_json)
          end
        end
      end
    end
  end
end
