Gocreative::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Do not eager load code on boot.
  config.eager_load = false

  # Show full error reports and disable caching.
  config.consider_all_requests_local       = true

  # Don't care if the mailer can't send.
  config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger.
  config.active_support.deprecation = :log

  # Raise an error on page load if there are pending migrations
  config.active_record.migration_error = :page_load

  # Debug mode disables concatenation and preprocessing of assets.
  # This option may cause significant delays in view rendering with a large
  # number of complex assets.
  config.assets.debug = true
  config.assets.precompile += %w(dashboard_js/dashboard.js dashboard_css/dashboard.css, *.js, dashboard_css/signin.css, dashboard_css/styles.css)

  #For Mailer
  config.action_mailer.default_url_options = { host: 'localhost', port: 3000 }
  
  #load mail server settings
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_deliveries = true
  
  config.action_mailer.delivery_method = :letter_opener
  config.action_mailer.default_options = { from: 'contact@booleans.in' }

  config.action_controller.perform_caching = true
  config.cache_store = :memory_store

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
