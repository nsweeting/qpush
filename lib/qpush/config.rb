module QPush
  class << self
    def configure
      reset
      yield(config)
    end

    def config
      @config ||= Config.new
    end

    def reset
      @config = nil
      @connection_pool = nil
    end
  end

  class Config
    DEFAULTS = {
      redis_url: ENV['REDIS_URL'],
      database_url: ENV['DATABASE_URL'],
      redis_pool: 10,
      database_pool: 10,
      workers: 2,
      stats_namespace: 'qpush:v1:stats',
      queue_threads: 2,
      queue_namespace: 'qpush:v1:queue',
      perform_threads: 2,
      perform_namespace: 'qpush:v1:perform',
      delay_threads:1,
      delay_namespace: 'qpush:v1:delay',
      priorities: 5
    }.freeze

    attr_accessor :workers, :queue_threads, :queue_namespace, :delay_threads,
                  :delay_namespace, :perform_threads, :perform_namespace,
                  :stats_namespace, :redis_url, :redis_pool, :priorities,
                  :database_url, :database_pool, :database_adapter

    def initialize
      DEFAULTS.each { |key, value| send("#{key}=", value) }
    end

    def worker_options
      {
        perform_threads: perform_threads,
        queue_threads: queue_threads,
        delay_threads: delay_threads
      }
    end

    def manager_options
      {
        workers: workers,
        options: worker_options
      }
    end

    def redis
      {
        size: redis_pool,
        url: redis_url
      }
    end

    def perform_lists
      (1..priorities).collect { |num| "#{perform_namespace}:#{num}" }
    end
  end
end
