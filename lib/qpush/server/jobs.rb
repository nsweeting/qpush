module QPush
  module Server
    module JobHelpers
      def bump_success
        @total_success += 1
      end

      def bump_fail
        @total_fail += 1
      end

      def retry_job?
        @retry_max > @total_fail
      end

      def perform_job?
        @start_at < Time.now.to_i && @cron.empty?
      end

      def delay_job?
        (@start_at > Time.now.to_i && @cron.empty?) || cron_job?
      end

      def cron_job?
        @start_at < Time.now.to_i && !@cron.empty?
      end

      def dead_job?
        @total_fail >= @retry_max
      end

      def cron_at
        CronParser.new(@cron).next(Time.now).to_i
      rescue => e
        raise ServerError, e.message
      end

      def delay_until
        @cron.empty? ? @start_at : cron_at
      end

      def retry_at
        Time.now.to_i + ((@total_fail**4) + 15 + (rand(30) * (@total_fail + 1)))
      end
    end

    class Job < QPush::Job::Base
      include QPush::Server::JobHelpers
      include ObjectValidator::Validate

      attr_reader :api

      def initialize(options)
        super
        @api = JobApi.new(self)
      end
    end

    class JobValidator
      include ObjectValidator::Validator

      validates :klass,
                with: { proc: proc { |j| Object.const_defined?(j.klass) },
                        msg: 'has not been defined' }
      validates :cron,
                with: { proc: proc { |j| j.cron.empty? ? true : CronParser.new(j.cron) },
                        msg: 'is not a valid expression' }
      validates :id, type: String
      validates :args, type: Hash
      validates :created_at, type: Integer
      validates :start_at, type: Integer
      validates :retry_max, type: Integer
      validates :total_fail, type: Integer
      validates :total_success, type: Integer
    end

    class JobApi
      def initialize(job)
        @job = job
      end

      def queue
        QPush.redis.with do |conn|
          conn.incr("#{QPush.config.stats_namespace}:queued")
          conn.lpush("#{QPush.config.queue_namespace}", @job.to_json)
        end
      end

      def execute
        execute = Execute.new(@job)
        execute.call
      end

      def perform
        QPush.redis.with do |conn|
          conn.incr("#{QPush.config.stats_namespace}:performed")
          conn.lpush("#{QPush.config.perform_namespace}:#{@job.priority}", @job.to_json)
        end
      end

      def delay
        send_to_delay('delayed', @job.delay_until)
      end

      def retry
        send_to_delay('retries', @job.retry_at)
      end

      def setup
        fail unless @job.valid?
        perform if @job.perform_job?
        delay if @job.delay_job?
      rescue
        raise ServerError, 'Invalid job: ' + @job.errors.full_messages.join(' ')
      end

      private

      def send_to_delay(stat, time)
        QPush.redis.with do |conn|
          conn.incr("#{QPush.config.stats_namespace}:#{stat}")
          conn.zadd(QPush.config.delay_namespace, time, @job.to_json)
        end
      end
    end
  end
end
