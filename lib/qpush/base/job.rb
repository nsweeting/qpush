module QPush
  class << self
    def job(options)
      job = Client::Job.new(options)
      job.queue
    end
  end

  module Base
    class Job
      attr_accessor :klass, :id, :priority, :created_at, :start_at,
                    :cron, :retry_max, :total_success, :total_fail,
                    :run_time, :namespace
      attr_reader :args, :failed

      def initialize(options = {})
        options = defaults.merge(options)
        options.each { |key, value| send("#{key}=", value) }
      end

      def args=(args)
        @args =
          if args.is_a?(String) then JSON.parse(args)
          else args
          end
      rescue JSON::ParserError
        @args = nil
      end

      def failed=(failed)
        @failed = failed == 'true' || failed == true
      end

      def to_json
        { klass: @klass,
          id: @id,
          priority: @priority,
          created_at: @created_at,
          start_at: @start_at,
          cron: @cron,
          retry_max: @retry_max,
          total_fail: @total_fail,
          total_success: @total_success,
          failed: @failed,
          args: @args }.to_json
      end

      private

      def defaults
        { id: SecureRandom.urlsafe_base64,
          args: {},
          priority: 3,
          created_at: Time.now.to_i,
          start_at: Time.now.to_i - 1,
          cron: '',
          retry_max: 10,
          total_fail: 0,
          total_success: 0,
          failed: false,
          namespace: 'default' }
      end
    end
  end
end
