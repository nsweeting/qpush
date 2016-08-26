# QPush Base
require 'qpush/base'

module QPush
  module Client
    include QPush::Base::ConfigHelper
    include QPush::Base::RedisHelper

    class << self
      def config
        @config ||= Config.new
      end
    end

    class Config < QPush::Base::Config; end

    class Job < QPush::Base::Job
      def queue
        Client.redis do |conn|
          conn.hincrby("#{QPush::Base::KEY}:#{@namespace}:stats", 'queued', 1)
          conn.lpush("#{QPush::Base::KEY}:#{@namespace}:queue", to_json)
        end
      end
    end
  end
end
