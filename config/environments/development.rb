Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports.
  config.consider_all_requests_local = true

  # Enable/disable caching. By default caching is disabled.
  if Rails.root.join('tmp/caching-dev.txt').exist?
    config.action_controller.perform_caching = true

    config.cache_store = :memory_store
    config.public_file_server.headers = {
      'Cache-Control' => 'public, max-age=172800'
    }
  else
    config.action_controller.perform_caching = false

    config.cache_store = :null_store
  end

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  config.action_mailer.perform_caching = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations.
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true

  # Suppress logger output for asset requests.
  config.assets.quiet = true

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # Use an evented file watcher to asynchronously detect changes in source code,
  # routes, locales, etc. This feature depends on the listen gem.
  config.file_watcher = ActiveSupport::EventedFileUpdateChecker

  # To allow root/admin users to sign up without an invite:
  ENV['ROOT_INVITE_CODE'] = 'BOGUS'
  ENV['EXTERNAL_URL'] = 'http://localhost:3000'

  # For devise
  config.action_mailer.default_url_options = {host: 'localhost', port: 3000}
  config.action_mailer.asset_host = 'http://localhost:3000'
  ENV['SENDGRID_USERNAME'] = 'app45653070@heroku.com'
  ENV['SENDGRID_PASSWORD'] = 'dpj7r2gr2223'

  # For sendgrid
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = {
      :address        => 'smtp.sendgrid.net',
      :port           => '587',
      :authentication => :plain,
      :user_name      => ENV['SENDGRID_USERNAME'],
      :password       => ENV['SENDGRID_PASSWORD'],
      :enable_starttls_auto => true
  }

  ENV['MIXPANEL_KEY'] = '193a285a569c812e4938b7c38a9357da'
  ENV['FACEBOOK_APP_ID'] = ''

  # Limit size of log file, and limit number of log files to one
  # TODO: Figure this shizz out for rails 5.0
  # config.logger = Logger.new(config.paths['log'].first, 1, 1.megabytes)

  # Raises error for missing translations
  # config.action_view.raise_on_missing_translations = true

  # # UNCOMMENT THESE TO DIAGNOSE PERFORMANCE ISSUES
  #
  # # These two lines will provide a fancy HTML view of how long every action on a given page takes
  # require 'rack-mini-profiler'
  # Rack::MiniProfilerRails.initialize!(Rails.application)
  #
  # This block will output an informative warning to the console anytime we are not including
  # the proper associations in an action
  config.after_initialize do
    Bullet.enable = true
    Bullet.rails_logger = true
  end
end
