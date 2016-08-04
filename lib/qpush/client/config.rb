module QPush
  module Client
    include QPush::Base::ConfigHelper

    class << self
      def config
        @config ||= Config.new
      end
    end

    class Config < QPush::Base::Config; end
  end
end
