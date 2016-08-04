
class RedisTest < Minitest::Test
  def assert_redis_creates_valid_connection
    assert QPush.redis { |c| c.ping }
  end

  def test_redis_pool_is_a_connection_pool
    assert QPush.redis_pool.is_a?(ConnectionPool)
  end

  def test_redis_keys_are_available
    keys = [:delay,
            :queue,
            :perform,
            :stats,
            :heart,
            :jobs,
            :crons,
            :history,
            :morgue]
    keys.each { |key| assert QPush.keys.send(key) }
  end

  def test_redis_keys_creates_perform_lists
    list = QPush.keys.perform_lists
    assert list.is_a?(Array)
    assert list.first == QPush.keys.perform + ':1'
  end
end
