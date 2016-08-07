module QPush
  module Web
    module Apis
      class Retries
        def initialize(start, count)
          @start = start ? start.to_i : 0
          @count = count ? count.to_i : 10
          @jobs = nil
        end

        def call
          retrieve_jobs
          update_jobs
          trim_jobs
        end

        private

        def retrieve_jobs
          @jobs = Web.redis do |conn|
            conn.zrange(Web.keys.delay, 0, -1, with_scores: true)
          end
        end

        def update_jobs
          @jobs.map! do |job|
            hash = JSON.parse(job.first, symbolize_names: true).merge(perform_at: job.last)
            next unless hash[:failed]
            hash
          end
        end

        def trim_jobs
          @jobs.compact!
          @jobs[@start, @count]
        end
      end
    end
  end
end
