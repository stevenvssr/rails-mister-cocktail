require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module RailsMisterCocktail
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Ensure this is set to true for Active Storage compatibility with newer versions
    config.active_storage.replace_on_assign_to_many = true

    # Recommended default for cookies
    config.action_dispatch.cookies_same_site_protection = :lax

    config.assets.paths << Rails.root.join('node_modules') # For modern apps, but good to add

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
