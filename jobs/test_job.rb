class TestJob
  include QPush::Server::JobRegister

  def call
    puts 'Hello from TestJob'
  end
end
