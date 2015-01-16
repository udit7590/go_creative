class Admin::UsersController < ::ApplicationController
  layout 'dashboard'
  before_action :authenticate_admin_user!
  before_action :load_user, only: [:verify, :show]
  before_action :check_not_verified, only: :verify
  before_action :check_user_details_complete, only: :verify
  
  def index
    @users = User.all.order_by_creation.page(params[:page]).per(20)
  end

  def show
    @projects = @user.projects
    @contributions = @user.contributions.order(created_at: :desc)
  end

  def verify
    if @user.verify(current_admin_user)
      redirect_to admin_project_path(params[:project_id]), notice: 'User details verified.'
    else
      redirect_to admin_project_path(params[:project_id]), alert: 'Cannot verify as user details are incomplete.'
    end
  end

  protected

    def load_user
      @user = User.find_by(id: (params[:user_id] || params[:id]))
      unless @user
        redirect_to admin_root_path, alert: "No Such user found with ID: #{ params[:user_id] }"
      end
    end

    def check_not_verified
      if @user.verified?
        redirect_to admin_project_path(params[:project_id]), alert: 'User details are already verified'
      end
    end

    def check_user_details_complete
      unless @user.complete?
        redirect_to admin_project_path(params[:project_id]), alert: 'Cannot verify as user details are incomplete.'
      end
    end

end
