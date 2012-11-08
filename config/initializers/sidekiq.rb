require 'sidekiq/middleware/client/unique_job'

Sidekiq.configure_client do |config|
  config.redis = { namespace: 'scout' }

  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::Client::UniqueJob
  end
end

Sidekiq.configure_server do |config|
  config.redis = { namespace: 'scout' }
end
