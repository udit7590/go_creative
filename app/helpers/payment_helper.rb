module PaymentHelper
  def payment_error_messages(model_object)
    return '' if model_object.errors.empty?

    messages = model_object.errors.full_messages.map { |msg| content_tag(:li, msg) }.join
    sentence = I18n.t('errors.failure', scope: [:payments])

    html = <<-HTML
    <div id="error_explanation" class='alert alert-error'>
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end

  def transaction_error(transaction)
    return '' if transaction.nil? || transaction.message.nil?

    html = <<-HTML
    <div id="error_explanation" class='alert alert-error'>
      <p>Unable to receive payment for the following reason: <br />#{transaction.message}</p>
    </div>
    HTML
  end

end
