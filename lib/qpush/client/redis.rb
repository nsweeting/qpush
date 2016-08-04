module QPush
  module Client
    class << self
      def redis
        redis_pool.with do |conn|
          yield conn
        end
      end

      def redis_pool
        @redis_pool ||= QPush::Base::RedisPool.create(Client.config.redis_pool,
                                                      Client.config.redis_url)
      end
    end
  end
end
