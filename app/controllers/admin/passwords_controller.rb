class Admin::PasswordsController < ::Devise::PasswordsController
  layout 'dashboard_login'

  def after_resetting_password_path_for(admin)
    admin_root_path
  end
end
