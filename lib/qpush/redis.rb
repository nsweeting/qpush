module QPush
  class << self
    attr_reader :redis_pool

    def redis
      @redis_pool ||= RedisPool.create
    end

    def keys
      @keys ||= Rediskeys.new
    end
  end

  class RedisPool
    def self.create
      ::ConnectionPool.new(size: QPush.config.redis_pool) do
        ::Redis.new(url: QPush.config.redis_url)
      end
    end
  end

  class Rediskeys
    BASE = 'qpush:v1'.freeze
    KEYS = [:delay,
            :queue,
            :perform,
            :stats,
            :heart,
            :jobs,
            :crons,
            :history,
            :morgue]

    attr_reader :delay, :queue, :perform, :stats, :heart, :jobs,
                :history, :morgue

    def initialize
      build_keyspaces
    end

    def perform_lists
      (1..QPush.config.priorities).collect { |num| "#{perform}:#{num}" }
    end

    private

    def build_keyspaces
      KEYS.each do |key|
        instance_variable_set("@#{key}", "#{BASE}:#{QPush.config.namespace}:#{key}")
      end
    end
  end
end
