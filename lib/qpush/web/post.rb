module QPush
  module Web
    class Post
      class << self
        def create(params)
          create = Apis::Create.new(params)
          create.call
        end
      end
    end
  end
end
