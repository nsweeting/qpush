module QPush
  module Web
    module Apis
      class QueueDelayed
        def initialize(id, score)
          @id = id
          @score = score
        end

        def call
          QPush.redis.with do |conn|
            @conn = conn
            watch_delay { retrieve_delay }
          end
        end

        private

        def retrieve_delay
          delays = @conn.zrangebyscore(QPush.keys.delay, @score, @score)
          delays.each

        # Performs a watch on our delay list
        #
        def watch_delay
          @conn.watch(QPush.keys.delay) do
            yield if block_given?
          end
        end
