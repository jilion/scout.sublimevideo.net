source 'https://rubygems.org'

ruby '1.9.3'

gem 'bundler', '~> 1.2.0.pre.1'

gem 'rails',   '3.2.6'
gem 'sinatra', require: nil
gem 'pg',      '~> 0.14.0'
gem 'squeel',  '~> 1.0.6'
gem 'mongoid', '~> 3.0.0.rc'

# Internals
gem 'fog',                 '~> 1.4.0'
gem 'carrierwave',         '~> 0.6.2', require: ['carrierwave', 'carrierwave/processing/mime_types']
gem 'carrierwave-mongoid', github: 'jnicklas/carrierwave-mongoid', branch: 'mongoid-3.0', require: 'carrierwave/mongoid'
gem 'mini_magick',         '~> 3.4.0'
gem 'sidekiq',             '~> 2.0.2'
gem 'heroku',              '~> 2.28.8'

# Views
gem 'slim',                '~> 1.2.2'
gem 'jquery-rails',        '~> 2.0.2'
gem 'acts-as-taggable-on', '~> 2.3.1'

# Auth / Admin
gem 'devise', '~> 2.1.2'
# gem 'activeadmin',         '~> 0.4.4'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.5'
  gem 'coffee-rails', '~> 3.2.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  # gem 'uglifier', '>= 1.0.3'
  gem 'closure-compiler', '~> 1.1.6'
end

group :production do
  gem 'oink', '~> 0.9.3'
end

group :staging, :production do
  gem 'thin',         '~> 1.4.1'
  gem 'rpm_contrib',  '~> 2.1.11'
  gem 'newrelic_rpm', '~> 3.4.0.1'
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

  # Javascript test
  # gem 'jasminerice'
end

group :test do
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'webmock',  '~> 1.6'
  gem 'typhoeus', '~> 0.2'

  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'factory_girl_rails' # loaded in spec_helper Spork.each_run
end

group :tools do
  gem 'wirble'
  gem 'foreman'
  gem 'brakeman'

  # Guard
  gem 'growl'
  gem 'coolline'
  gem 'guard-pow'
  # gem 'guard-redis', github: 'guard/guard-redis'
  # gem 'guard-redis', path: '~/github/guard-redis'
  gem 'guard-rspec'
end
