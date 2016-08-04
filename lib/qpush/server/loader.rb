module QPush
  module Server
    # The Loader will 'require' all jobs within the users job folder.
    # The job folder is specified in the config.
    #
    class JobLoader
      # Provides a shortend caller.
      #
      def self.call
        loader = new
        loader.call
      end

      # Entrypoint to load all jobs.
      #
      def call
        flush_jobs
        load_jobs
      end

      private

      # Removes old jobs from the redis job list.
      #
      def flush_jobs
        Server.redis { |c| c.del(QPush::Base::KEY + ':jobs') }
      end

      # Requires user jobs that are specified from the config.
      #
      def load_jobs
        Dir[Dir.pwd + "#{Server.config.jobs_path}/**/*.rb"].each do |file|
          require file
        end
      end
    end
  end
end
