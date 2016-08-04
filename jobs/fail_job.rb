class FailJob
  include QPush::Server::JobRegister

  def initialize(options)
    @option = options
  end

  def call
    fail
  end
end
