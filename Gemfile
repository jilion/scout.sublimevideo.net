source 'https://rubygems.org'
source 'https://8dezqz7z7HWea9vtaFwg:@gem.fury.io/me/' # thibaud@jilion.com account

ruby '2.0.0'

gem 'rails', '4.0.0'
gem 'sublime_video_private_api', '~> 1.5' # hosted on gemfury
gem 'mongoid'

# Internals
gem 'fog'
gem 'carrierwave', require: ['carrierwave', 'carrierwave/processing/mime_types']
gem 'carrierwave-mongoid', require: 'carrierwave/mongoid'
gem 'mini_magick'
gem 'sidekiq'
gem 'autoscaler'
gem 'heroku-api'
gem 'oj'
gem 'honeybadger'

gem 'rack-status'

# Views
gem 'slim'
gem 'coffee-rails'
gem 'jquery-rails'

# Assets
gem 'uglifier'
gem 'sass-rails'

group :staging, :production do
  gem 'unicorn', require: false
  gem 'rack-devise_cookie_auth'
  gem 'newrelic_rpm'
end

group :development do
  gem 'rack-livereload'
  gem 'quiet_assets'

  # Guard
  gem 'ruby_gntp', require: false
  gem 'guard-pow', require: false
  gem 'guard-rspec', require: false
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails'
end

group :test do
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'factory_girl_rails' # loaded in spec_helper Spork.each_run
end
