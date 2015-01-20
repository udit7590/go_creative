class ContributionMailer < ActionMailer::Base
  layout 'devise_email'

  def payment_success(user, project, pdf)
    @user = user
    @project = project
    attachments['contribution_invoice.pdf'] = pdf
    mail(to: @user.email, subject: 'Thanks for your contribution')
  end

end
