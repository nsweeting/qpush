module QPush
  module Web
    class Server < Sinatra::Base
      before do
        content_type :json
      end

      get '/stats' do
        Get.stats.to_json
      end

      get '/delays' do
        Get.delays(params[:start].to_i, params[:end].to_i).to_json
      end

      get '/crons' do
        Get.crons(params[:start].to_i, params[:end].to_i).to_json
      end

      get '/fails' do
        Get.fails(params[:start].to_i, params[:end].to_i).to_json
      end
    end
  end
end
