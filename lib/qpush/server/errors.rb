module QPush
  class ServerError < StandardError
    def initialize(msg = nil)
      @message = msg
      log_error
    end

    def message
      "The following error occured: #{@message}"
    end

    private

    def log_error
      Server.log.err("Server Error - #{@message}")
    end
  end
end
