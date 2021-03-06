class RegistrationsController < Devise::RegistrationsController
  respond_to :html, :json

  #FIXME: Refactor code if resource_saved
  def create
    build_resource(sign_up_params)
    resource_saved = resource.save
    yield resource if block_given?
    if resource_saved
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up
        sign_in(resource_name, resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
      end

      @redirect_to_path = request.referer
      
      respond_to do |format|
        format.js { render 'registrations/success_registration' }
      end
    else
      # Errors occurred while registration
      clean_up_passwords resource
      @validatable = devise_mapping.validatable?
      
      @minimum_password_length = resource_class.password_length.min if @validatable

      respond_to do |format|
        format.js { render 'registrations/error_registration' }
      end
    end
  end

  protected
  
    def configure_sign_up_parameters
      devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:first_name, :last_name, :email, :password, :password_confirmation, :country, :state, :city, :pincode, :address_line_1, :address_line_2, :phone_number) }
    end

    def after_update_path_for(resource)
      edit_account_path
    end

end
