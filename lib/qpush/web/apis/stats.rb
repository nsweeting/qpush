module QPush
  module Web
    module Apis
      class Stats
        DEFAULTS = {
          'queued' => 0,
          'success' => 0,
          'failed' => 0,
          'performed' => 0,
          'dead' => 0,
          'retries' => 0,
          'delayed' => 0,
          'current_queue' => 0,
          'percent_success' => 100.00
        }.freeze

        def initialize
          @stats = nil
        end

        def call
          retrieve_stats
          apply_defaults
          calculate_stats
          @stats
        end

        private

        def retrieve_stats
          @stats = Web.redis do |conn|
            conn.hgetall(Web.keys.stats)
          end
        end

        def apply_defaults
          @stats.each { |k, v| @stats[k] = v.to_i }
          @stats = DEFAULTS.merge(@stats)
        end

        def calculate_stats
          @stats['percent_success'] = calculate_success
          @stats['current_queue'] = calculate_current
        end

        def calculate_success
          (100.00 - ((@stats['failed'].to_f / @stats['performed'].to_f) * 100.00)).round(2)
        end

        def calculate_current
          Web.redis do |c|
            Web.keys.perform_list.collect { |list| c.llen(list) }.reduce(:+)
          end
        end
      end
    end
  end
end
