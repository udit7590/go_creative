require 'exception_notification/rails'

Gocreative::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Code is not reloaded between requests.
  config.cache_classes = true

  # Eager load code on boot. This eager loads most of Rails and
  # your application in memory, allowing both thread web servers
  # and those relying on copy on write to perform better.
  # Rake tasks automatically ignore this option for performance.
  config.eager_load = true

  # Full error reports are disabled and caching is turned on.
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store
  
  # Enable Rack::Cache to put a simple HTTP cache in front of your application
  # Add `rack-cache` to your Gemfile before enabling this.
  # For large-scale production use, consider using a caching reverse proxy like nginx, varnish or squid.
  # config.action_dispatch.rack_cache = true

  # Disable Rails's static asset server (Apache or nginx will already do this).
  config.serve_static_assets = false

  # Compress JavaScripts and CSS.
  config.assets.js_compressor = Uglifier.new(harmony: true)
  # config.assets.css_compressor = :sass

  # Do not fallback to assets pipeline if a precompiled asset is missed.
  config.assets.compile = false

  # Generate digests for assets URLs.
  config.assets.digest = true

  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.1'

  # Specifies the header that your server uses for sending files.
  # config.action_dispatch.x_sendfile_header = "X-Sendfile" # for apache
  # config.action_dispatch.x_sendfile_header = 'X-Accel-Redirect' # for nginx

  # Force all access to the app over SSL, use Strict-Transport-Security, and use secure cookies.
  # config.force_ssl = true

  # Set to :debug to see everything in the log.
  config.log_level = :info

  # Prepend all log lines with the following tags.
  # config.log_tags = [ :subdomain, :uuid ]

  # Use a different logger for distributed setups.
  # config.logger = ActiveSupport::TaggedLogging.new(SyslogLogger.new)

  # Use a different cache store in production.
  # config.cache_store = :mem_cache_store

  # Enable serving of images, stylesheets, and JavaScripts from an asset server.
  # config.action_controller.asset_host = "http://assets.example.com"

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  # config.assets.precompile += %w( search.js )
  config.assets.precompile += %w(dashboard_js/dashboard.js dashboard_css/dashboard.css, *.js, dashboard_css/signin.css, dashboard_css/styles.css)

  # Ignore bad email addresses and do not raise email delivery errors.
  # Set this to true and configure the email server for immediate delivery to raise delivery errors.
  # config.action_mailer.raise_delivery_errors = false

  # Enable locale fallbacks for I18n (makes lookups for any locale fall back to
  # the I18n.default_locale when a translation can not be found).
  config.i18n.fallbacks = true

  # Send deprecation notices to registered listeners.
  config.active_support.deprecation = :notify

  # Disable automatic flushing of the log to improve performance.
  # config.autoflush_log = false

  # Use default logging formatter so that PID and timestamp are not suppressed.
  config.log_formatter = ::Logger::Formatter.new

  #For Mailer
  config.action_mailer.default_url_options = { host: 'booleans-crowdfunding.herokuapp.com' }

  #load mail server settings
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    user_name: ENV['SENDGRID_USERNAME'],
    password: ENV['SENDGRID_PASSWORD'], 
    address: 'smtp.sendgrid.net',
    port: 587,
    authentication: :plain,
    enable_starttls_auto: true
  }

  config.action_mailer.default_options = { from: 'contact@booleans.in' }

  config.after_initialize do
    # Send requests to the gateway's test servers
    ActiveMerchant::Billing::Base.mode = :test

    ::GATEWAY = ActiveMerchant::Billing::PaypalGateway.new(
      login: 'udit-facilitator_api1.vinsol.com',
      password: '9ZDXLHZMG6MTYWPE',
      signature: 'AFcWxV21C7fd0v3bYYYRCpSSRl31AYKb-gwzAAGTZTmeRpmVwK9jlrP8'
      )
  end

  config.paperclip_defaults = {
    storage: :s3,
    s3_credentials: "#{Rails.root}/config/s3.yml",
    url: ':s3_domain_url',
    bucket: ENV['S3_BUCKET'],
    path: '/:class/:attachment/:id_partition/:style/:filename',
    default_url: '/images/:attachment/missing_:style.jpg'
  }

end

ExceptionNotification.configure do |config|
  # Ignore additional exception types.
  # ActiveRecord::RecordNotFound, AbstractController::ActionNotFound and ActionController::RoutingError are already added.
  # config.ignored_exceptions += %w{ActionView::TemplateError CustomError}

  # Adds a condition to decide when an exception must be ignored or not.
  # The ignore_if method can be invoked multiple times to add extra conditions.
  # config.ignore_if do |exception, options|
  #   not Rails.env.production?
  # end

  # Notifiers =================================================================

  # Email notifier sends notifications by email.
  config.add_notifier :email, {
    email_prefix: 'Go Creative Exception Notification key: "value", ',
    sender_address: %{"notifier" <contact@booleans.in>},
    exception_recipients: %w{udit@booleans.in}
  }

end
