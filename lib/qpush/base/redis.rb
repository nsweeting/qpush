module QPush
  module Base
    KEY = 'qpush:v1'.freeze
    SUB_KEYS = [:delay,
                :queue,
                :perform,
                :stats,
                :heart,
                :crons,
                :history,
                :morgue]

    module Redis
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def redis
          redis_pool.with do |conn|
            yield conn
          end
        end

        def redis_pool
          @redis_pool ||= build_pool(config.redis_pool, config.redis_url)
        end

        def build_keys(namespace, priorities)
          name = "#{QPush::Base::KEY}:#{namespace}"
          keys = Hash[QPush::Base::SUB_KEYS.collect { |key| [key, "#{name}:#{key}"] }]
          keys[:perform_list] = (1..5).collect { |num| "#{keys[:perform]}:#{num}" }
          keys
        end

        def build_pool(pool, url)
          ::ConnectionPool.new(size: pool) do
            ::Redis.new(url: url)
          end
        end
      end
    end
  end
end
