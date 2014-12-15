class ConfirmationsController < Devise::ConfirmationsController
  def show
    if params[:confirmation_token].present?
      @original_token = params[:confirmation_token]
    elsif params[resource_name].try(:[], :confirmation_token).present?
      @original_token = params[resource_name][:confirmation_token]
    end
    self.resource = resource_class.find_by_confirmation_token Devise.token_generator.
    digest(self, :confirmation_token, @original_token)

    if self.resource.valid?
      self.resource.confirm!
      set_flash_message :notice, :confirmed
      sign_in_and_redirect resource_name, resource
    else
      render action: 'show'
    end

  end

  private
  def permitted_params
    params.require(resource_name).permit(:confirmation_token, :password, :password_confirmation)
  end

end
