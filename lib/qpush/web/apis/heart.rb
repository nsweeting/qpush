module QPush
  module Web
    module Apis
      class Heart
        def call
          heart = Web.redis { |c| c.get(Web.keys[:heart]) }
          { status: !heart.nil?, namespace: 'default' }
        end
      end
    end
  end
end
