require 'test_helper'

module Server
  class ApisTest < Minitest::Test
    def test_job_creation_adds_api_connection
      job = QPush::Server::Job.new(klass: 'TestJob')
      assert job.instance_variable_defined?(:@api)
    end

    def test_api_wrapper_queue
      job = QPush::Server::Job.new(klass: 'TestJob')
      wrapper = QPush::Server::ApiWrapper.new(job)
      assert wrapper.queue
    end

    def test_api_wrapper_perform
      job = QPush::Server::Job.new(klass: 'TestJob')
      wrapper = QPush::Server::ApiWrapper.new(job)
      assert wrapper.perform
    end

    def test_api_wrapper_execute
      job = QPush::Server::Job.new(klass: 'TestJob')
      wrapper = QPush::Server::ApiWrapper.new(job)
      assert wrapper.execute
    end

    def test_api_wrapper_delay
      job = QPush::Server::Job.new(klass: 'TestJob')
      wrapper = QPush::Server::ApiWrapper.new(job)
      assert wrapper.delay
    end

    def test_api_wrapper_retry
      job = QPush::Server::Job.new(klass: 'TestJob')
      wrapper = QPush::Server::ApiWrapper.new(job)
      assert wrapper.retry
    end

    def test_api_wrapper_morgue
      job = QPush::Server::Job.new(klass: 'TestJob')
      wrapper = QPush::Server::ApiWrapper.new(job)
      assert wrapper.morgue
    end

    def test_api_wrapper_setup
      job = QPush::Server::Job.new(klass: 'TestJob')
      wrapper = QPush::Server::ApiWrapper.new(job)
      byebug
      assert wrapper.setup
    end
  end
end
