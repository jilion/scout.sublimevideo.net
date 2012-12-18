require 'sidekiq/middleware/client/unique_job'

Sidekiq.configure_client do |config|

  config.client_middleware do |chain|
    chain.add Sidekiq::Middleware::Client::UniqueJob
  end
end
