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
      namespace: 'default',
      queue_threads: 2,
      perform_threads: 2,
      delay_threads: 1,
      priorities: 5,
      jobs_path: '/jobs'
    }.freeze

    attr_accessor :workers, :queue_threads, :namespace, :delay_threads,
                  :perform_threads, :redis_url, :redis_pool, :priorities,
                  :database_url, :database_pool, :jobs_path

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
  end
end
