source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '5.2.4.2'

# Use postgresql as the database for Active Record
gem 'pg'

# Use SCSS for stylesheets
#gem 'sass-rails', '~> 4.0.0'

# Use Uglifier as compressor for JavaScript assets
gem 'uglifier'

# Use CoffeeScript for .js.coffee assets and views
#gem 'coffee-rails', '~> 4.0.0'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'

# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'

# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder'

group :doc do
  # bundle exec rake doc:rails generates the API under doc/api.
  gem 'sdoc', require: false
end

# Use ActiveModel has_secure_password
gem 'bcrypt-ruby'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano', group: :development

# Use debugger
gem 'byebug', group: [:development, :test]

# Use Devise
gem 'devise'

# Use Paperclippaperclip
gem 'paperclip'
#For Paperclip s3 storage
gem 'aws-sdk'
gem 'paperclip-dropbox'

# Required for deployment on heroku
gem 'rails_12factor', group: :production

group :development, :test do
  gem 'rspec-rails'
  gem 'shoulda-matchers'
  gem 'shoulda-callback-matchers'
  gem 'factory_bot_rails'
  gem 'dotenv-rails', '~> 2.2', require: 'dotenv/rails-now'
end

gem 'non-stupid-digest-assets', group: :production

#For Pagination
gem 'kaminari'

#For State Machine
gem 'aasm'

#For mails in test and development
gem 'letter_opener', group: [:development, :test]

# gem 'quiet_assets', group: :development

# For payment
gem 'activemerchant'
gem 'stripe', git: 'https://github.com/stripe/stripe-ruby'

# For scheduling
gem 'daemons'
gem 'delayed_job_active_record'

# For PDF
gem 'prawn'
gem 'prawn-table'

# For production exception 
gem 'exception_notification', group: :production

# For test coverage
gem 'simplecov', require: false, group: :test

gem 'whenever', require: false
