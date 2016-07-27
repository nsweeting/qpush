module QPush
  module Web
    class Server < Sinatra::Base
      set :public_folder, Gem::Specification.find_by_name('qpush').gem_dir + '/lib/qpush/web/public'

      before do
        pass if request.path_info == '/'
        content_type :json
        headers 'Access-Control-Allow-Origin' => '*',
                'Access-Control-Allow-Methods' => ['OPTIONS', 'GET', 'POST']
      end

      get '/' do
        File.read(File.join(settings.public_folder, 'index.html'))
      end

      get '/stats' do
        Get.stats
      end

      get '/heartbeat' do
        Get.heartbeat
      end

      get '/history' do
        Get.history
      end

      get '/jobs' do
        Get.jobs
      end

      post '/queue_delayed' do
        Post.queue_delayed(params[:id], params[:score])
      end

      get '/delays' do
        Get.delays(params[:start].to_i, params[:count].to_i).to_json
      end

      get '/crons' do
        Get.crons(params[:start].to_i, params[:count].to_i)
      end

      get '/retries' do
        Get.retries(params[:start], params[:count])
      end

      get '/morgue' do
        Get.morgue(params[:start].to_i, params[:count].to_i)
      end
    end
  end
end
