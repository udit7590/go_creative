class ConfirmationsController < Devise::ConfirmationsController
  before_action :load_original_token, only: :show

  def show
    @resource = resource_class.find_by_confirmation_token Devise.token_generator.
    digest(self, :confirmation_token, @original_token)
    if @resource
      if @resource.valid?
        if @resource.confirm!
          set_flash_message :notice, :confirmed
          sign_in_and_redirect resource_name, @resource
        else
          set_flash_message :alert, :confirm_token_expired
          redirect_to action: :new
        end
      end
    else
      if !sign_in_if_confirmed(params[:email])
        set_flash_message :alert, :invalid_user
        redirect_to action: :index, controller: :home
      end
    end

  end

  private

    def permitted_params
      params.require(resource_name).permit(:confirmation_token, :password, :password_confirmation)
    end

    def load_original_token
      if params[:confirmation_token].present?
        @original_token = params[:confirmation_token]
      elsif params[resource_name].try(:[], :confirmation_token).present?
        @original_token = params[resource_name][:confirmation_token]
      else
        false
      end
    end

    def after_resending_confirmation_instructions_path_for(resource_name)
      root_path
    end

    def sign_in_if_confirmed(email)
      @resource = User.find_by_email(email)
      if @resource && @resource.confirmed?
        set_flash_message :notice, :already_confirmed_resource
        sign_in_and_redirect resource_name, @resource
      end
      @resource
    end

end
