module QPush
  module Web
    module Apis
      class Jobs
        def initialize
          @jobs = nil
        end

        def call
          retrieve_jobs
          update_jobs
        end

        private

        def retrieve_jobs
          Web.redis { |c| @jobs = c.smembers("#{QPush.keys.jobs}") }
        end

        def update_jobs
          @jobs.map! { |job| { klass: job } }
        end
      end
    end
  end
end
