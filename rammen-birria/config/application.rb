require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module RammenBirria
  class Application < Rails::Application
    config.load_defaults 8.0
    config.api_only = true
    config.i18n.default_locale = :es
    config.i18n.available_locales = %i[es en]
    config.i18n.fallbacks = true
    config.autoload_lib(ignore: %w[assets tasks])

    config.middleware.use ActionDispatch::Cookies
    config.middleware.use Rack::Attack

    config.generators do |g|
      g.test_framework :rspec,
        request_specs: true,
        routing_specs: false,
        view_specs: false,
        helper_specs: false,
        controller_specs: false
      g.template_engine :jbuilder
      g.helper false
      g.stylesheets false
      g.assets false
    end
  end
end
