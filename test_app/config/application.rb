require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

formatter     = Logfmt::Formatter.new(justify: true, escape_strings: false)
::SLog = Logfmt::Logger.new(STDOUT, formatter: formatter)
::MLog = Logfmt::Metrics.new(::SLog)

module TestApp
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.
  end
end
