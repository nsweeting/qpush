module QPush
  module Web
    class Get
      STATS = [:delayed,
               :queued,
               :performed,
               :retries,
               :success,
               :failed].freeze

      class << self
        def stats
          stats = {}
          namespace = QPush.config.stats_namespace
          QPush.redis.with do |conn|
            STATS.each { |s| stats[s] = conn.get("#{namespace}:#{s}") }
          end
          stats
        end

        def delays(s, e)
          jobs = Get.all_delays[s, e]

          jobs.map! { |job| JSON.parse(job.first).merge(perform_at: job.last) }
        end

        def crons(s, e)
          jobs = Get.all_delays

          jobs.map! do |job|
            hash = JSON.parse(job.first).merge(perform_at: job.last)
            hash['cron'].empty? ? next : hash
          end

          jobs.compact![s, e]

          { total: jobs.count, jobs: jobs }
        end

        def fails(s, e)
          jobs = Get.all_delays

          jobs.map! do |job|
            hash = JSON.parse(job.first).merge(perform_at: job.last)
            hash['cron'].empty? && hash['total_fail'] > 0 ? hash : next
          end
          jobs.compact![s, e]

          { total: jobs.count, jobs: jobs }
        end

        def all_delays
          QPush.redis.with do |conn|
            conn.zrange(QPush.config.delay_namespace, 0, -1, with_scores: true)
          end
        end
      end
    end
  end
end
