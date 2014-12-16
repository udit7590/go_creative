class PasswordsController < ::Devise::PasswordsController

  before_action :check_user_confirmed, only: :create

  def after_resetting_password_path_for(resource)
    root_path
  end
  
  def after_sending_reset_password_instructions_path_for(resource)
    root_path
  end

  protected

    def check_user_confirmed
      user = User.find_by_email(params[:user][:email])
      return if user.nil?
      set_flash_message :notice, :reset_password_needs_confirmation
      redirect_to new_confirmation_path(:user) unless user && user.confirmed?
    end

end
