module QPush
  module Server
    module Apis
      class Fail < Base
        def initialize(job, error)
          @job = job
          @error = error
        end

        def call
          update_job
          stat_increment
          log_error
          update_history
        end

        private

        def update_job
          @job.mark_failed
          @job.retry if @job.retry_job?
          @job.morgue if @job.dead_job?
        end

        def stat_increment
          QPush.redis.with { |c| c.hincrby(QPush.keys.stats, 'failed', 1) }
        end

        def log_error
          Server.log.err("Job FAILED | #{@job.klass} | #{@job.id} | #{@error.message}")
        end

        def update_history
          History.call(@job, false, @error)
        end
      end
    end
  end
end
