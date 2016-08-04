module QPush
  module Base
    KEY = 'qpush:v1'.freeze

    class RedisPool
      def self.create(pool, url)
        ::ConnectionPool.new(size: pool) do
          ::Redis.new(url: url)
        end
      end
    end
  end
end
