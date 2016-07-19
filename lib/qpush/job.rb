module QPush
  class << self
    def job(options)
      job = Job::Wrapper.new(options)
      job.queue
    end
  end

  module Job
    class << self
      def included(base)
        base.extend(ClassMethods)
      end
    end

    module ClassMethods
      def queue(options)
        QPush.job(options.merge(klass: name))
      end
    end

    module Base
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
          total_success: 0
        }
      end
    end

    class Wrapper
      include QPush::Job::Base

      attr_accessor :klass, :id, :priority, :created_at, :start_at,
                    :cron, :retry_max, :total_success, :total_fail,
                    :args

      def initialize(options = {})
        options = defaults.merge(options)
        options.each { |key, value| send("#{key}=", value) }
      end

      def queue
        QPush.redis.with do |conn|
          conn.incr("#{QPush.config.stats_namespace}:queued")
          conn.lpush("#{QPush.config.queue_namespace}", to_json)
        end
      end
    end
  end
end
