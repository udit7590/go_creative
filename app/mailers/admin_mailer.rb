class AdminMailer < Devise::Mailer
  # gives access to all helpers defined within `application_helper`
  helper :application

  # eg. `confirmation_url`
  include Devise::Controllers::UrlHelpers

  # to make sure that you mailer uses the devise views
  default template_path: 'devise/mailer'

  default from: 'site@gocreative.com'
end
