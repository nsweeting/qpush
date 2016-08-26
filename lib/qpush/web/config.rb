module QPush
  module Web
    include QPush::Base::ConfigHelper
    include QPush::Base::RedisHelper

    class << self
      def config
        @config ||= Config.new
      end
    end

    class Config < QPush::Base::Config; end
  end
end
