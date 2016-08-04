module QPush
  module Server
    module Apis
      class History < Base
        def initialize(job, status, error)
          @status = status
          @klass = job.klass
          @args = job.args
          @performed = Time.now.to_i
          @error = error ? error.message : nil
        end

        def call
          update_history
        end

        private

        def update_history
          Server.redis do |c|
            c.lpush(Server.keys.history, to_json)
            c.ltrim(Server.keys.history, 0, 10)
          end
        end

        def to_json
          { status: @status,
            klass: @klass,
            args: @args,
            performed: @performed,
            error: @error }.to_json
        end
      end
    end
  end
end
