require File.expand_path('../boot', __FILE__)

require 'action_controller/railtie'
require 'sprockets/railtie'

Bundler.require *Rails.groups(assets: %w(development test))

module ScoutSublimevideo
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # http://ileitch.github.com/2012/03/24/rails-32-code-reloading-from-lib.html
    config.watchable_dirs['lib'] = [:rb]

    # Enable the asset pipeline
    config.assets.enabled = true

    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '1.0'

    # http://guides.rubyonrails.org/asset_pipeline.html#precompiling-assets
    # For faster asset precompiles, you can partially load your application
    # by setting config.assets.initialize_on_precompile to false
    # in config/application.rb, though in that case templates cannot see
    # application objects or methods. Heroku requires this to be false.
    config.assets.initialize_on_precompile = false

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = 'utf-8'

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true
  end
end

require 'env_yaml'
