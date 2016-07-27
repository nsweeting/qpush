class FailJob
  include QPush::Job

  def initialize(options)
    @option = options
  end

  def call
    fail
  end
end
