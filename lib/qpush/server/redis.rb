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

    class RedisKeys
      KEYS = [:delay,
              :queue,
              :perform,
              :stats,
              :heart,
              :crons,
              :history,
              :morgue]

      attr_reader :delay, :queue, :perform, :stats, :heart,
                  :crons, :history, :morgue

      def initialize(options)
        @namespace = options[:namespace] || 'default'
        @priorities = options[:priorities] || 5
        build_keyspaces
      end

      def perform_list
        @perform_list ||= (1..@priorities).collect { |num| "#{perform}:#{num}" }
      end

      private

      def build_keyspaces
        KEYS.each do |key|
          instance_variable_set("@#{key}", "#{QPush::Base::KEY}:#{@namespace}:#{key}")
        end
      end
    end
  end
end
