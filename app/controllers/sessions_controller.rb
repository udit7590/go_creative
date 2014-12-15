class SessionsController < ::Devise::SessionsController
  layout 'dashboard_login'

  def create
    resource = warden.authenticate!(scope: resource_name, recall: 'sessions#failure')
    sign_in_and_redirect(resource_name, resource)
  end
 
  def sign_in_and_redirect(resource_or_scope, resource=nil)
    scope = Devise::Mapping.find_scope!(resource_or_scope)
    resource ||= resource_or_scope
    sign_in(scope, resource) unless warden.user(scope) == resource
    @redirect_to_path = request.env["HTTP_REFERER"]
    set_flash_message :notice, :signed_in
    respond_to do |format|
      format.js { render 'sessions/login' }
    end
  end
 
  def failure
    return render js: "alert('Invalid credentials, please try again.')"
  end

  protected
  def after_sign_in_path_for(resource)
    root_path
  end

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

end
