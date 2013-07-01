source 'https://rubygems.org'
source 'https://8dezqz7z7HWea9vtaFwg@gem.fury.io/me/' # thibaud@jilion.com account

ruby '2.0.0'

gem 'bundler'

gem 'rails', '3.2.13'
gem 'sublime_video_private_api', '~> 1.5' # hosted on gemfury
gem 'mongoid'

# Internals
gem 'fog',                 '~> 1.12'
gem 'carrierwave',         '~> 0.8', require: ['carrierwave', 'carrierwave/processing/mime_types']
gem 'carrierwave-mongoid', '~> 0.5', require: 'carrierwave/mongoid'
gem 'mini_magick'
gem 'sidekiq'
gem 'autoscaler'
gem 'heroku-api'
gem 'oj'
gem 'honeybadger'

gem 'rack-status'

# Views
gem 'slim'
gem 'jquery-rails'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'uglifier'
end
gem 'sass-rails'

group :staging, :production do
  gem 'unicorn'
  gem 'rack-devise_cookie_auth'
  gem 'newrelic_rpm'
end

group :development do
  gem 'rack-livereload'
  gem 'quiet_assets'
  gem 'pry-rails'
end

group :development, :test do
  gem 'dotenv-rails'
  gem 'rspec-rails'
  gem 'debugger'
end

group :test do
  gem 'shoulda-matchers'

  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'factory_girl_rails' # loaded in spec_helper Spork.each_run
end

group :tools do
  gem 'wirble'
  gem 'foreman'

  # Guard
  gem 'ruby_gntp'
  gem 'rb-fsevent'

  gem 'guard-pow'
  gem 'guard-rspec'
end
