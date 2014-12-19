class Admin::UsersController < ::ApplicationController
  layout 'dashboard'

  def index
    @users = User.all.order_by_creation.page(params[:page]).per(20)
  end

end
