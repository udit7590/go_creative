class SessionsController < ::Devise::SessionsController

  before_action :check_user_confirmation, only: :create

  def create
    resource = warden.authenticate!(scope: resource_name, recall: 'sessions#failure')
    sign_in_and_redirect(resource_name, resource)
  end
 
  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    @redirect_to_path = request.referer
    set_flash_message :notice, :signed_in
    respond_to do |format|
      format.js { render 'sessions/login' }
    end
  end
 
  def failure
    render 'sessions/error_login', locals: { user_confirmed: true }
  end

  protected
    def after_sign_in_path_for(resource)
      root_path
    end

    def after_sign_out_path_for(resource_or_scope)
      root_path
    end

    def check_user_confirmation
      user = User.find_by_email(params[:user][:email])
      if user && !user.confirmed?
        render 'sessions/error_login', locals: { user_confirmed: false }
      end
    end

end
