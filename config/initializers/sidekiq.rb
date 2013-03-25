if ENV['HEROKU_APP']
  require 'autoscaler/sidekiq'
  require 'autoscaler/heroku_scaler'
  heroku = Autoscaler::HerokuScaler.new

  Sidekiq.configure_client do |config|
    config.client_middleware do |chain|
      chain.add Autoscaler::Sidekiq::Client, 'scout' => heroku
    end
  end

  Sidekiq.configure_server do |config|
    if database_url = ENV['DATABASE_URL']
      ENV['DATABASE_URL'] = "#{database_url}?pool=15"
      ActiveRecord::Base.establish_connection
    end

    config.server_middleware do |chain|
      chain.add Autoscaler::Sidekiq::Server, heroku, 60, %w[scout]
    end
  end
end
