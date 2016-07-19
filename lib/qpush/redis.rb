module QPush
  class << self
    attr_reader :redis_pool

    def redis
      @redis_pool ||= RedisPool.create
    end
  end

  class RedisPool
    def self.create
      ::ConnectionPool.new(size: QPush.config.redis_pool) do
        ::Redis.new(url: QPush.config.redis_url)
      end
    end
  end
end
