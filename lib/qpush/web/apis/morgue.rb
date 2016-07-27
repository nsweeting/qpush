module QPush
  module Web
    module Apis
      class Morgue
        def initialize(start, count)
          @morgue = nil
          @start = start
          @count = count
        end

        def call
          retrieve_morgue
          update_morgue
        end

        private

        def retrieve_morgue
          @morgue = QPush.redis.with do |conn|
            conn.lrange(QPush.keys.morgue, @start, @start + @count)
          end
        end

        def update_morgue
          @morgue.map! { |i| JSON.parse(i) }
        end
      end
    end
  end
end