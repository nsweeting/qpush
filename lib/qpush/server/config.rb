module QPush
  module Server
    include QPush::Base::ConfigHelper
    include QPush::Base::RedisHelper

    class << self
      attr_accessor :keys

      def config
        @config ||= Config.new
      end
    end

    class Config < QPush::Base::Config
      include ObjectValidator::Validate

      SERVER_DEFAULTS = {
        database_url: ENV['DATABASE_URL'],
        database_pool: 10,
        jobs_path: '/jobs',
        workers: [WorkerConfig.new] }.freeze

      attr_accessor :database_url, :database_pool, :jobs_path, :workers

      def initialize
        super
        SERVER_DEFAULTS.each { |key, value| send("#{key}=", value) }
      end

      def validate!
        return if valid?
        fail ServerError, errors.full_messages.join(' ')
      end
    end

    class ConfigValidator
      include ObjectValidator::Validator

      validates :redis, with: { proc: proc { Server.redis { |c| c.ping && c.quit } },
                                msg: 'could not be connected with' }
      validates :workers, with: { proc: proc { |c| c.workers.is_a?(Array) && c.workers.count > 0 },
                                  msg: 'is not a valid Array of WorkerConfigs' }
      validates :configs, with: { proc: proc { |c| c.workers.all? { |w| w.is_a?(WorkerConfig) } },
                                  msg: 'are not valid WorkerConfig objects' }
      validates :jobs_path, with: { proc: proc { |c| Dir.exist?(Dir.pwd + Server.config.jobs_path) },
                                    msg: 'is not a valid directory' }
    end
  end
end
