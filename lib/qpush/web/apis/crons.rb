module QPush
  module Web
    module Apis
      class Crons
        def initialize(start, count)
          @jobs = nil
          @start = start ? start.to_i : 0
          @count = count ? count.to_i : 10
        end

        def call
          retrieve_delays
          filter_crons
        end

        private

        def retrieve_delays
          @jobs = Web.redis do |conn|
            conn.zrange(Web.keys[:delay], 0, -1, with_scores: true)
          end
        end

        def filter_crons
          @jobs.map! do |job|
            hash = JSON.parse(job.first).merge(perform_at: job.last)
            hash['cron'].empty? ? next : hash
          end
          @jobs.compact[@start, @count]
        end
      end
    end
  end
end
