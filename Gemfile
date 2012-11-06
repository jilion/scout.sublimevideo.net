source 'https://rubygems.org'

ruby '1.9.3'

gem 'bundler', '~> 1.2.0'

gem 'rails',   '3.2.8'
gem 'sinatra', require: nil
gem 'pg',      '~> 0.14.0'
gem 'squeel',  '~> 1.0.11'
gem 'mongoid', '~> 3.0.6'

# Internals
gem 'fog',                 '~> 1.6.0'
gem 'carrierwave',         '~> 0.6.2', require: ['carrierwave', 'carrierwave/processing/mime_types']
gem 'carrierwave-mongoid', github: 'jnicklas/carrierwave-mongoid', branch: 'mongoid-3.0', require: 'carrierwave/mongoid'
gem 'mini_magick',         '~> 3.4.0'
gem 'sidekiq',             '~> 2.5.1'
gem 'heroku-api',          '~> 0.3.2'

# Views
gem 'slim',                '~> 1.2.2'
gem 'jquery-rails',        '~> 2.0.2'
gem 'acts-as-taggable-on', '~> 2.3.1'

# Auth / Admin
gem 'devise', '~> 2.1.2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'coffee-rails', '~> 3.2.2'

  # gem 'uglifier', '>= 1.0.3'
  gem 'closure-compiler', '~> 1.1.7'
end
gem 'sass-rails',   '~> 3.2.5'

group :staging, :production do
  gem 'thin',         '~> 1.4.1'
  gem 'rpm_contrib',  '~> 2.1.11'
  gem 'newrelic_rpm', '~> 3.4.1'
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
  gem 'brakeman'
  gem 'heroku'

  # Guard
  gem 'growl'
  gem 'coolline'
  gem 'guard-pow'
  # gem 'guard-redis', github: 'guard/guard-redis'
  # gem 'guard-redis', path: '~/github/guard-redis'
  gem 'guard-rspec'
end
