module QPush
  module Server
    class Execute
      def initialize(job)
        @job = job
      end

      def call
        measure_run_time { job_object.call }
        ExecutionSuccess.call(@job)
      rescue => e
        ExecutionFail.call(@job, e)
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

    class ExecutionFail
      def self.call(*args)
        failed = ExecutionFail.new(*args)
        failed.call
      end

      def initialize(job, error)
        @job = job
        @error = error
      end

      def call
        update_job
        stat_increment
        log_error
      end

      private

      def update_job
        @job.bump_fail
        @job.api.retry if @job.retry_job?
      end

      def stat_increment
        QPush.redis.with do |c|
          c.incr("#{QPush.config.stats_namespace}:dead") if @job.dead_job?
          c.incr("#{QPush.config.stats_namespace}:failed")
        end
      end

      def log_error
        Server.log.err("Job FAILED | #{@job.klass} | #{@job.id} | #{@error.message}")
      end
    end

    class ExecutionSuccess
      def self.call(*args)
        success = ExecutionSuccess.new(*args)
        success.call
      end

      def initialize(job)
        @job = job
      end

      def call
        update_job
        stat_increment
        log_success
      end

      private

      def update_job
        @job.bump_success
        @job.api.delay if @job.delay_job?
      end

      def stat_increment
        QPush.redis.with do |c|
          c.incr("#{QPush.config.stats_namespace}:success")
        end
      end

      def log_success
        Server.log.info("Job SUCCESS | #{@job.klass} with ID: #{@job.id} | #{@job.run_time}")
      end
    end
  end
end
