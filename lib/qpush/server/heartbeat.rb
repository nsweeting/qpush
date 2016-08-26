module QPush
  module Server
    # The Heartbeat worker periodically updates the heart key.
    # The key is set with an expiry. This helps to indicate if the QPush server
    # is currently active.
    #
    class Heartbeat
      def initialize
        @done = false
      end

      # Starts our heartbeat process. This will run until instructed to stop.
      #
      def start
        until @done
          Server.redis { |c| c.setex(Server.keys[:heart], 30, true) }
          sleep 15
        end
      end

      # Shutsdown our heartbeat process.
      #
      def shutdown
        @done = true
      end
    end
  end
end
