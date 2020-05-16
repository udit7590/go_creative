class AdminMailer < Devise::Mailer
  # gives access to all helpers defined within `application_helper`
  helper :application

  # eg. `confirmation_url`
  include Devise::Controllers::UrlHelpers

  # to make sure that you mailer uses the devise views
  default template_path: 'devise/mailer'

  #FIXME_AB: should not hardcode this email, should be configurable through env based constants.
  default from: 'contact@booleans.in'
end
