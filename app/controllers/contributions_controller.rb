class ContributionsController < ApplicationController
  
  before_action :store_location
  before_action :authenticate_user!
  before_action :load_project, only: [:new, :create]
  before_action :load_user, only: [:new, :create]
  before_action :build_contribution, only: [:new]

  # Checks if the project is not orphan. It is only a security check.
  # FUTURE: Do some critical action here
  before_action :check_orphan_project, only: [:new, :create]

  # TODO: Decide whether project owner can contribute
  before_action :check_project_owner, only: [:new, :create]

  # To capture user's PAN and address details (Proceed if not verified, but display message)
  before_action :check_user_details, only: [:new, :create]

  # To make sure project end date has not expired
  before_action :check_project_end_date, only: [:new, :create]

  # To make sure no contributions are accepted if project state is invalid
  before_action :check_project_state, only: [:new, :create]

  # TODO: To make sure amount being contributed meets the project's minimum criterai
  before_action :check_minimum_amount, only: [:new, :create]

  # TODO: No need for more contributions if amount has been completely collected
  before_action :check_if_more_contribution_required, only: [:new, :create]

  def index
  end

  def new
    render :new
  end

  def create
    @contribution = @project.contributions.build(user_id: @user.id, amount: params[:contribution][:amount])
    if(@contribution.save)
      flash[:notice] = 'Your donation has been accepted'
      redirect_to root_path
    else
      flash[:alert] = 'Unable to accept'
      redirect_to root_path
    end
  end

  protected

    def contribution_params
      params.require(:contribution).permit(:amount, :project_id, :user_id)
    end

    def load_project
      @project = Project.find_by(id: (params[:project_id]))
      unless @project
        flash[:alert] = I18n.t :no_project, scope: [:projects, :views]
        redirect_to controller: :home, action: :index
      end
    end

    def load_user
      @user = current_user
      unless @user
        flash[:alert] = I18n.t :no_user, scope: [:errors, :views]
        redirect_to controller: :home, action: :index
      end
    end

    def build_contribution
      @contribution = @project.contributions.build(user_id: @user.id)
      if params[:charity_project]
        @contribution.amount = params[:charity_project][:min_amount_per_contribution]
      else
        @contribution.amount = params[:investment_project][:min_amount_per_contribution]
      end
    end

    def check_orphan_project
      unless @project.user_id
        flash[:alert] = I18n.t :orphan_project, scope: [:projects, :views]
        redirect_to controller: :home, action: :index
      end
    end

    def check_project_owner
      if @project.user_id == @user.id
        flash[:alert] = I18n.t :project_owner_cannot_contribute, scope: [:contributions, :errors]
        redirect_to controller: :home, action: :index
      end
    end

    # Pass the project id and params in session to be able to receive later
    def check_user_details
      unless @user.complete?
        missing_page = (@user.missing_info_page == :missing_pan) ? :update_pan_details : :update_address_details
        missing_message = (@user.missing_info_page == :missing_pan) ? :pan_details_incomplete : :address_details_incomplete
        flash[:alert] = I18n.t missing_message, scope: [:projects, :views]
        session[:process_project_id] = @project.id
        session[:request_data] = params
        session[:request_url] = request.fullpath 
        redirect_to controller: :accounts, action: missing_page
      end
    end

    def check_project_end_date
      if !@project.end_date && @project.end_date < DateTime.current
        flash[:alert] = I18n.t :project_expired, scope: [:contributions, :errors]
        redirect_to controller: :home, action: :index
      end
    end

    def check_project_state
      unless @project.published?
        flash[:alert] = I18n.t :project_not_published, scope: [:contributions, :errors]
        redirect_to controller: :home, action: :index
      end
    end

    # TODO: replace params[:amount] with apt param
    def check_minimum_amount
      # if params[:amount] < @project.min_amount_per_contribution 
      #   flash[:alert] = I18n.t :project_not_published, scope: [:contributions, :errors]
      #   redirect_to controller: :projects, action: :show
      # end
    end

    #TODO
    def check_if_more_contribution_required; end
    

end