module QPush
  module Server
    module Apis
      class Success < Base
        def initialize(job)
          @job = job
        end

        def call
          update_job
          stat_increment
          log_success
          update_history
        end

        private

        def update_job
          @job.mark_success
          @job.delay if @job.delay_job?
        end

        def stat_increment
          QPush.redis.with do |c|
            c.hincrby(QPush.keys.stats, 'success', 1)
          end
        end

        def log_success
          Server.log.info("Job SUCCESS | #{@job.klass} with ID: #{@job.id} | #{@job.run_time}")
        end

        def update_history
          History.call(@job, true, nil)
        end
      end
    end
  end
end
