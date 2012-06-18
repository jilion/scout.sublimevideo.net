source 'https://rubygems.org'

ruby '1.9.3'

gem 'bundler', '~> 1.2.0.pre.1'

gem 'rails',   '3.2.5'
gem 'sinatra', require: nil
gem 'pg',      '~> 0.13.0'
gem 'squeel',  '~> 1.0.0'
gem 'mongoid', '~> 3.0.0.rc'

# Internals
gem 'fog',                 '~> 1.3.1'
gem 'carrierwave',         '~> 0.6.2', require: ['carrierwave', 'carrierwave/processing/mime_types']
gem 'carrierwave-mongoid', github: 'digitalplaywright/carrierwave-mongoid', branch: 'mongoid-3.0', require: 'carrierwave/mongoid'
gem 'mini_magick',         '~> 3.4.0'
gem 'sidekiq',             '~> 2.0.1'
gem 'phantomjs.rb',        '>= 0.0.4'

# Auth / invitations
gem 'devise', '~> 2.0.1'

gem 'slim'
gem 'activeadmin',         '~> 0.4.4'
gem 'jquery-rails'
gem 'acts-as-taggable-on', '~> 2.2.2'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer', :platforms => :ruby

  gem 'uglifier', '>= 1.0.3'
end

group :staging, :production do
  gem 'thin'
end

group :development do
  gem 'rack-livereload'
  gem 'silent-postgres'
  gem 'quiet_assets'
  gem 'pry-rails'
end

group :development, :test do
  gem 'rspec-core'
  gem 'rspec-rails'
  gem 'debugger'

  # Javascript test
  gem 'jasminerice'
  # Rails routes view
  gem 'sextant'
end

group :test do
  gem 'shoulda-matchers'
  gem 'capybara'
  gem 'capybara-email'
  gem 'capybara-webkit'
  gem 'show_me_the_cookies'
  gem 'webmock',  '~> 1.6'
  gem 'typhoeus', '~> 0.2'
  gem 'vcr',      '~> 1.10'

  gem 'database_cleaner'
  gem 'factory_girl'
  gem 'factory_girl_rails' # loaded in spec_helper Spork.each_run
end

group :tools do
  gem 'wirble'
  gem 'heroku'
  gem 'foreman'
  gem 'powder'
  gem 'brakeman'

  # Guard
  gem 'growl'
  gem 'coolline'
  gem 'guard', github: 'guard/guard', branch: 'coolline'
  gem 'guard-pow'
  gem 'guard-livereload'
  # gem 'guard-redis', github: 'guard/guard-redis'
  # gem 'guard-redis', path: '~/github/guard-redis'
  gem 'guard-rspec'
  gem 'guard-jasmine'
end
