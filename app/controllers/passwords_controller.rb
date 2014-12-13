class PasswordsController < ::Devise::PasswordsController

  def after_resetting_password_path_for(resource)
    root_path
  end
  
end
