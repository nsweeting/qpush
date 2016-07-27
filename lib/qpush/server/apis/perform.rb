module QPush
  module Server
    module Apis
      class Perform < Base
        def initialize(job)
          @job = job
        end

        def call
          perform_job
        end

        private

        def perform_job
          QPush.redis.with do |conn|
            conn.hincrby(QPush.keys.stats, 'performed', 1)
            conn.lpush("#{QPush.keys.perform}:#{@job.priority}", @job.to_json)
          end
        end
      end
    end
  end
end
