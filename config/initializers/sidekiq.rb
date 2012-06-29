require 'sidekiq/middleware/client/unique_jobs'
require 'sidekiq/middleware/server/unique_jobs'
require 'sidekiq/middleware/client/autoscale'
require 'sidekiq/middleware/server/autoscale'

Sidekiq.configure_client do |config|
  config.redis = { namespace: 'scout' }
  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::Client::UniqueJobs
    chain.add Sidekiq::Middleware::Client::Autoscale
  end
end

Sidekiq.configure_server do |config|
  config.redis = { namespace: 'scout' }
  config.server_middleware do |chain|
    chain.add Sidekiq::Middleware::Server::Autoscale
    chain.add Sidekiq::Middleware::Server::UniqueJobs
  end
end
