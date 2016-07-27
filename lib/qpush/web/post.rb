module QPush
  module Web
    class Post
      class << self
        def queue_delayed(id, score)
          queue = Apis::QueueDelayed.new(id)
          queue.call.to_json
        end
