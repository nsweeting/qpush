module QPush
  module Server
    module Apis
      class Execute < Base
        def call
          measure_run_time { job_object.call }
          Success.call(@job)
        rescue => e
          Fail.call(@job, e)
        end

        private

        def measure_run_time
          start = Time.now
          yield
          finish = Time.now
          @job.run_time = "#{((finish - start) * 1000.0).round(3)} ms"
        end

        def job_object
          klass = Object.const_get(@job.klass)
          @job.args.empty? ? klass.new : klass.new(@job.args)
        end
      end
    end
  end
end
