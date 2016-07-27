module QPush
  module Server
    # The Loader will 'require' all jobs within the users job folder.
    # The job folder is specified in the config.
    #
    class Loader
      # Provides a shortend caller.
      #
      def self.call
        jobs = Loader.new
        jobs.call
      end

      # Entrypoint to load all jobs.
      #
      def call
        remove_old
        load_jobs
      end

      private

      # Removes old jobs from the redis job list.
      #
      def remove_old
        QPush.redis.with { |c| c.del(QPush.keys.jobs) }
      end

      # Requires user jobs that are specified from the config.
      #
      def load_jobs
        Dir[Dir.pwd + "#{QPush.config.jobs_path}/**/*.rb"].each do |file|
          require file
        end
      end
    end
  end
end
