module QPush
  module Web
    class << self
      def redis
        redis_pool.with do |conn|
          yield conn
        end
      end

      def redis_pool
        @redis_pool ||= QPush::Base::RedisPool.create(Web.config.redis_pool,
                                                      Web.config.redis_url)
      end
    end
  end
end
