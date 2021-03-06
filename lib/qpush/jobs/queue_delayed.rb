module QPush
  module Jobs
    class QueueDelayed
      attr_accessor :id, :score

      def initialize(options)
        options.each { |key, value| send("#{key}=", value) }
      end

      def call
        'hello'
      end
    end
  end
end
