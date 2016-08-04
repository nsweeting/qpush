module QPush
  module Server
    module Apis
      class Setup < Base
        def call
          invalid_job && return unless @job.valid?
          setup_job
        end

        private

        def setup_job
          Perform.call(@job) if @job.perform_job?
          Delay.call(@job, :delay) if @job.delay_job?
        end

        def invalid_job
          Server.log.err("Worker #{Server.worker.id} | Job INVALID | #{@job.klass} | #{@job.id} | #{@job.errors.full_messages.join(' ')}")
        end
      end
    end
  end
end
