class ContributionMailer < ActionMailer::Base
  layout 'devise_email'

  def payment_success(contribution, transaction)
    @user = contribution.user
    @project = contribution.project
    attachments['contribution_invoice.pdf'] = generate_pdf(contribution, transaction)
    mail(to: @user.email, subject: 'Thanks for your contribution')
  end

  def project_cancelled(contribution, transaction)
    @user = contribution.user
    @project = contribution.project
    attachments['contribution_refunded.pdf'] = generate_pdf(contribution, transaction)
    mail(to: @user.email, subject: 'The project has been cancelled and we are refunding your contribution.')
  end

  def generate_pdf(contribution, transaction)
    ContributionPDF.new(contribution, transaction).render
  end

end
