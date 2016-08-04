module QPush
  module Server
    module Apis
      # A Base class for all API classes.
      #
      class Base
        def self.call(*args)
          api = new(*args)
          api.call
        end

        def initialize(job)
          @job = job
        end
      end
    end

    # The ApiWrapper provides simple wrapper functions for all the API
    # classes available for jobs. This provides a single entry point to
    # the API's for job objects.
    #
    class ApiWrapper
      def initialize(job)
        @job = job
      end

      def queue
        Apis::Queue.call(@job)
      end

      def perform
        Apis::Perform.call(@job)
      end

      def execute
        Apis::Execute.call(@job)
      end

      def delay
        Apis::Delay.call(@job, :delay)
      end

      def retry
        Apis::Delay.call(@job, :retry)
      end

      def morgue
        Apis::Morgue.call(@job)
      end

      def setup
        Apis::Setup.call(@job)
      end
    end
  end
end
