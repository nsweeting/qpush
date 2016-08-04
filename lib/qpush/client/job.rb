module QPush
  module Client
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
