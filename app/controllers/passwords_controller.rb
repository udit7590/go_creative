class PasswordsController < ::Devise::PasswordsController

  before_action :check_user_confirmed, only: :create
  # before_action :check_reset_password_token_valid, only: :edit

  def after_resetting_password_path_for(resource)
    root_path
  end
  
  def after_sending_reset_password_instructions_path_for(resource)
    root_path
  end

  protected

    def check_user_confirmed
      user = User.find_by_email(params[:user][:email])
      unless user
        set_flash_message :notice, :reset_password_needs_confirmation
        redirect_to new_confirmation_path(:user) unless user.try(:confirmed?)
      end
    end

    def check_reset_password_token_valid
      original_token       = params[:reset_password_token]
      reset_password_token = Devise.token_generator.digest(self, :reset_password_token, original_token)
      @resource = resource_class.find_or_initialize_with_error_by(:reset_password_token, reset_password_token)
      if !@resource.errors.empty?
        set_flash_message :alert, :invalid_token
        redirect_to action: :new
      end
    end

end
