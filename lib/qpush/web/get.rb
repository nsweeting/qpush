require 'byebug'

module QPush
  module Web
    class Get
      class << self
        def stats
          stats = Apis::Stats.new
          stats.call.to_json
        end

        def heartbeat
          heart = Apis::Heart.new
          heart.call.to_json
        end

        def history
          history = Apis::History.new
          history.call.to_json
        end

        def jobs
          jobs = Apis::Jobs.new
          jobs.call.to_json
        end

        def retries(s, c)
          retries = Apis::Retries.new(s, c)
          retries.call.to_json
        end

        def morgue(s, c)
          morgue = Apis::Morgue.new(s, c)
          morgue.call.to_json
        end

        def delays(s, e)
          jobs = Get.all_delays[s, e]

          jobs.map! { |job| JSON.parse(job.first).merge(perform_at: job.last) }
        end

        def crons(s, c)
          crons = Apis::Crons.new(s, c)
          crons.call.to_json
        end
      end
    end
  end
end
