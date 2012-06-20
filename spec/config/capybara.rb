require 'capybara/rspec'
require 'capybara/rails'

Capybara.javascript_driver = :webkit
Capybara.server_port = 2999

RSpec.configure do |config|
  config.before do
    Capybara.default_host = "http://scout.sublimevideo.dev"
    Capybara.reset_sessions!
  end
end
