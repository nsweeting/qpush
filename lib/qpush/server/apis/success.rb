module QPush
  module Server
    module Apis
      class Success < Base
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
          Server.redis do |c|
            c.hincrby(Server.keys[:stats], 'success', 1)
          end
        end

        def log_success
          Server.log.info("Worker #{Server.worker.id} | Job SUCCESS | #{@job.klass} with ID: #{@job.id} | #{@job.run_time}")
        end

        def update_history
          History.call(@job, true, nil)
        end
      end
    end
  end
end
