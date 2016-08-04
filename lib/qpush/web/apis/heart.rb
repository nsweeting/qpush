module QPush
  module Web
    module Apis
      class Heart
        def call
          heart = Web.redis { |c| c.get(QPush.keys.heart) }
          { status: !heart.nil?, namespace: QPush.config.namespace }
        end
      end
    end
  end
end
