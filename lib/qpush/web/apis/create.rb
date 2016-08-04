module QPush
  module Web
    module Apis
      class Create
        def initialize(params)
          @klass = params[:klass]
          @args = params[:args]
        end

        def call
          QPush.job(klass: @klass, args: @args)
        end
      end
    end
  end
end
