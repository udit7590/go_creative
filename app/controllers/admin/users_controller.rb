class Admin::UsersController < ::ApplicationController
  layout 'dashboard'
  before_action :authenticate_admin_user!
  
  def index
    @users = User.all.order_by_creation.page(params[:page]).per(20)
  end

end
