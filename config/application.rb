require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Scinote
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 5.1

    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Swap the Rack::MethodOverride with a wrapped middleware for WOPI handling
    require_relative '../app/middlewares/wopi_method_override'
    config.middleware.swap Rack::MethodOverride, WopiMethodOverride

    # Load all model concerns, including subfolders
    config.autoload_paths += Dir["#{Rails.root}/app/models/concerns/**/*.rb"]

    config.encoding = 'utf-8'

    config.active_job.queue_adapter = :delayed_job

    # Max uploaded file size in MB
    config.x.file_max_size_mb = (ENV['FILE_MAX_SIZE_MB'] || 50).to_i

    # Logging
    config.log_formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime}] #{severity}: #{msg}\n"
    end

    # Paperclip spoof checking
    Paperclip.options[:content_type_mappings] = {
      csv: 'text/plain',
      wopitest: ['text/plain', 'inode/x-empty']
    }

    # SciNote Core Application version
    VERSION = File.read(Rails.root.join('VERSION')).strip.freeze
  end
end
