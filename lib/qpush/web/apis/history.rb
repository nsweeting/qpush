module QPush
  module Web
    module Apis
      class History
        def initialize
          @jobs = nil
        end

        def call
          retrieve_jobs
          update_jobs
        end

        private

        def retrieve_jobs
          @jobs = Web.redis do |conn|
            conn.lrange(Web.keys[:history], 0, 10)
          end
        end

        def update_jobs
          @jobs.map! { |i| JSON.parse(i) }
        end
      end
    end
  end
end
