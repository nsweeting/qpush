module QPush
  module Server
    module Apis
      class Perform < Base
        def call
          perform_job
        end

        private

        def perform_job
          Server.redis do |conn|
            conn.hincrby(Server.keys[:stats], 'performed', 1)
            conn.lpush("#{Server.keys[:perform]}:#{@job.priority}", @job.to_json)
          end
        end
      end
    end
  end
end
