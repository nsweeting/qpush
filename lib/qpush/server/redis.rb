module QPush
  module Server
    class << self
      def redis
        redis_pool.with do |conn|
          yield conn
        end
      end

      def redis_pool
        @redis_pool ||= QPush::Base::RedisPool.create(Server.config.redis_pool,
                                                      Server.config.redis_url)
      end
    end

    module RedisKeys
      KEYS = [:delay,
              :queue,
              :perform,
              :stats,
              :heart,
              :crons,
              :history,
              :morgue]

      def self.build(namespace, priorities)
        name = "#{QPush::Base::KEY}:#{namespace}"
        keys = Hash[KEYS.collect { |key| [key, "#{name}:#{key}"] }]
        keys[:perform_list] = (1..5).collect { |num| "#{keys[:perform]}:#{num}" }
        keys
      end
    end
  end
end
