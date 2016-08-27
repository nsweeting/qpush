module QPush
  module Job
    class << self
      def included(base)
        _register_job(base)
        Server.log.info("* Job loaded: #{base.name}")
      end

      def _register_job(base)
        Server.jobs << base.name
        Server.redis { |c| c.sadd("#{QPush::Base::KEY}:jobs", base.name) }
      end
    end
  end

  module Server
    class << self
      def jobs
        @jobs ||= []
      end
    end

    class Job < QPush::Base::Job
      include QPush::Server::ApiWrapper
      include ObjectValidator::Validate

      def initialize(options)
        super
      end

      def mark_success
        @failed = false
        @total_success += 1
      end

      def mark_failed
        @failed = true
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

    class JobValidator
      include ObjectValidator::Validator

      validates :klass,
                with: { proc: proc { |j| Server.jobs.include?(j.klass) },
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
  end
end
