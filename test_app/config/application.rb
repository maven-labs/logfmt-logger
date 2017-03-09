require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module TestApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.



    formatter     = Logfmt::Formatter.new(justify: true, escape_strings: false)
    config.logger = Logfmt::Logger.new(STDOUT, formatter: formatter)

    ::MLog = Logfmt::Metrics.new(config.logger)

    config.log_tags =[ :uuid, :uuid ]
    # config.colorize_logging = false
  end
end
