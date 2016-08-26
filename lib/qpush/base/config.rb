module QPush
  module Base
    module ConfigHelper
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def configure
          reset
          yield(config)
        end

        def reset
          @config = nil
          @redis_pool = nil
        end
      end
    end

    class Config
      DEFAULTS = {
        redis_url: ENV['REDIS_URL'],
        redis_pool: 10
      }.freeze

      attr_accessor :redis_url, :redis_pool

      def initialize
        DEFAULTS.each { |key, value| send("#{key}=", value) }
      end

      def redis
        {
          size: redis_pool,
          url: redis_url
        }
      end
    end
  end
end
