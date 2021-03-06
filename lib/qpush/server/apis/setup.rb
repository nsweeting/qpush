module QPush
  module Server
    module Apis
      class Setup < Base
        def call
          @job.valid? ? setup_job : invalid_job
        end

        private

        def setup_job
          @job.perform if @job.perform_job?
          @job.delay if @job.delay_job?
        end

        def invalid_job
          Server.log.err("Worker #{Server.worker.id} | Job INVALID | #{@job.klass} | #{@job.id} | #{@job.errors.full_messages.join(' ')}")
        end
      end
    end
  end
end
