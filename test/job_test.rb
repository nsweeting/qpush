require 'test_helper'

class JobTest < Minitest::Test
  class JobTestClass
    include QPush::Job
  end

  def setup
    QPush.job(klass: 'TestJob')
  end

  def test_job_creation
    assert QPush.job(klass: 'TestJob')
  end

  def test_job_register
    jobs = QPush.redis { |c| c.smembers(QPush.keys.jobs) }
    assert jobs.include?('JobTest::JobTestClass')
  end

  def test_job_args_can_be_json
    json = { test: 1 }.to_json
    job = QPush::Job::ClientWrapper.new(klass: 'Test', args: json)
    assert job.args.is_a?(Hash)
  end

  def test_job_client_wrapper_queue
    pre_count = QPush.redis { |c| c.llen(QPush.keys.queue) }
    job = QPush::Job::ClientWrapper.new(klass: 'Test')
    job.queue
    post_count = QPush.redis { |c| c.llen(QPush.keys.queue) }
    assert pre_count < post_count
  end

  def test_job_queue_adds_queue_increment
    pre_count = QPush.redis { |c| c.hget(QPush.keys.stats, 'queued') }
    QPush.job(klass: 'TestJob')
    post_count = QPush.redis { |c| c.hget(QPush.keys.stats, 'queued') }
    assert pre_count < post_count
  end

  def test_job_defaults_are_assigned
    job = QPush::Job::ClientWrapper.new(klass: 'Test')
    assert job.priority == 3
    assert job.created_at >= Time.now.to_i - 5
    assert job.start_at >= Time.now.to_i - 5
    assert job.retry_max == 10
    assert job.total_fail == 0
    assert job.total_success == 0
    assert job.failed == false
    assert job.namespace == QPush.config.namespace
  end

  def test_job_to_json_creates_json
    job = QPush::Job::ClientWrapper.new(klass: 'Test')
    json = job.to_json
    assert JSON.parse(json)
  end

  def test_job_failed_can_be_bool_or_string
    job = QPush::Job::ClientWrapper.new(klass: 'Test')
    assert job.failed === false
    job.failed = 'false'
    assert job.failed === false
    job.failed = 'true'
    assert job.failed === true
  end
end
