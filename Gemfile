source 'https://rubygems.org'
source 'https://8dezqz7z7HWea9vtaFwg:@gem.fury.io/me/' # thibaud@jilion.com account

ruby '2.0.0'

gem 'rails', '~> 4.0.3'
gem 'sublime_video_private_api', '~> 1.6' # hosted on gemfury

# Databases
gem 'mongoid', '4.0.0.beta1'
gem 'mongoid-grid_fs', github: 'ahoward/mongoid-grid_fs'
gem 'kaminari'

# Internals
gem 'fog'
gem 'unf' # encoding for fog
gem 'carrierwave', require: ['carrierwave', 'carrierwave/processing/mime_types']
gem 'carrierwave-mongoid', require: 'carrierwave/mongoid'
gem 'mini_magick'
gem 'sidekiq'
gem 'oj' # Faster JSON
gem 'kgio' # Faster IO
gem 'faraday', '~> 0.8.9'

# Views
gem 'slim'
gem 'coffee-rails'
gem 'jquery-rails'

# Monitoring
gem 'rack-status'
gem 'honeybadger'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'uglifier'
  gem 'sass-rails'
end

group :staging, :production do
  gem 'unicorn', require: false
  gem 'rails_12factor'
  gem 'rack-devise_cookie_auth', github: 'jilion/rack-devise_cookie_auth'
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
  gem 'rspec-rails', '~> 3.0.0.beta1'
end

group :test do
  gem 'shoulda-matchers'
  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'factory_girl_rails' # loaded in spec_helper Spork.each_run
end
