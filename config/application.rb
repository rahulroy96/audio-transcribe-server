require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module AudioTranscriptionServer
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    # Only loads a smaller set of middleware suitable for API only apps.
    # Middleware like session, flash, cookies can be added back manually.
    # Skip views, helpers and assets when generating a new resource.
    config.api_only = true

    config.middleware.insert_before 0, Rack::Cors do
      allow do
        origins '127.0.0.1:3000', /\Ahttp:\/\/localhost(:\d+)?\z/, /\Ahttp:\/\/127\.0\.0\.\d{1,3}(:\d+)?\z/, /\Ahttp:\/\/127\.0\.0\.\d{1,3}(:\d+)?\z/, /\Ahttp:\/\/192\.168\.0\.\d{1,3}(:\d+)?\z/
        # The regular expression above allows CORS for all IPs starting with 192.168.0.

        resource '*', 
          headers: :any, 
          methods: [:get, :post, :put, :patch, :delete, :options, :head], 
          credentials: true
      end
    end
  end
end
