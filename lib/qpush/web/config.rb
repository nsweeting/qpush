module QPush
  module Web
    include QPush::Base::ConfigHelper

    class << self
      def config
        @config ||= Config.new
      end

      def keys
        @keys ||= QPush::Web::RedisKeys.new
      end
    end

    class Config < QPush::Base::Config; end
  end
end
