source 'https://rubygems.org'

ruby '1.9.3'

gem 'bundler'

gem 'rails', '3.2.13'
gem 'pg'
gem 'squeel'
gem 'mongoid'

# Internals
gem 'fog',                 '~> 1.6.0'
gem 'carrierwave',         '~> 0.6.2', require: ['carrierwave', 'carrierwave/processing/mime_types']
gem 'carrierwave-mongoid', github: 'jnicklas/carrierwave-mongoid', branch: 'mongoid-3.0', require: 'carrierwave/mongoid'
gem 'mini_magick'
gem 'sidekiq'
gem 'autoscaler'
gem 'heroku-api'
gem 'json'

# Views
gem 'slim'
gem 'jquery-rails'
gem 'acts-as-taggable-on'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails'
  gem 'closure-compiler'
end
gem 'sass-rails'

group :staging, :production do
  gem 'thin'
  gem 'rack-devise_cookie_auth'
  gem 'newrelic_rpm'
end

group :development do
  gem 'rack-livereload'
  gem 'silent-postgres'
  gem 'quiet_assets'
  gem 'pry-rails'
end

group :development, :test do
  gem 'rspec-rails', '~> 2.11.0'
  gem 'debugger'
end

group :test do
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'webmock',  '~> 1.8'
  gem 'typhoeus', '~> 0.2'

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
