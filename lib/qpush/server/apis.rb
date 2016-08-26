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

    # The ApiWrapper provides simple functions for all the API
    # classes available for jobs. This provides a single entry point to
    # the API's for job objects.
    #
    module ApiWrapper
      def queue
        Apis::Queue.call(self)
      end

      def perform
        Apis::Perform.call(self)
      end

      def execute
        Apis::Execute.call(self)
      end

      def delay
        Apis::Delay.call(self, :delay)
      end

      def retry
        Apis::Delay.call(self, :retry)
      end

      def morgue
        Apis::Morgue.call(self)
      end

      def setup
        Apis::Setup.call(self)
      end
    end
  end
end
