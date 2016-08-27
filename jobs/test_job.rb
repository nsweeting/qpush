class TestJob
  include QPush::Job
  
  def call
    puts 'Hello from TestJob'
  end
end
