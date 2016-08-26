module QPush
  module Server
    include QPush::Base::ConfigHelper
    include QPush::Base::RedisHelper

    class << self
      attr_accessor :worker, :keys

      def config
        @config ||= Config.new
      end

      def build_worker
        worker = WorkerConfig.new
        yield worker
        worker
      end
    end

    class WorkerConfig
      DEFAULTS = {
        namespace: 'default',
        priorities: 5,
        queue_threads: 2,
        perform_threads: 2,
        delay_threads: 1 }.freeze

      attr_accessor :perform_threads, :queue_threads, :delay_threads,
                    :namespace, :priorities

      def initialize(options = {})
        options = DEFAULTS.merge(options)
        options.each { |key, value| send("#{key}=", value) }
      end
    end

    class Config < QPush::Base::Config
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
    end
  end
end
