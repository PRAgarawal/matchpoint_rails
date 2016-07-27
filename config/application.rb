require_relative 'boot'

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Matchpoint
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.assets.paths << Rails.root.join('app', 'assets', 'third_party')
    config.assets.paths << Rails.root.join('app', 'assets', 'matchpoint')
    config.active_record.schema_format = :sql

    config.generators do |g|
      g.helper = false
      g.assets false
    end

    config.encoding = "utf-8"

    config.active_job.queue_adapter = :delayed_job
    Delayed::Worker.delay_jobs = Rails.env.production?

    # Add files in root of lib to build path
    config.autoload_paths += %W(#{config.root}/lib)
  end
end
