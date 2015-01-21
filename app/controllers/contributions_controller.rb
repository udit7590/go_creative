class ContributionsController < ApplicationController
  
  before_action :store_location
  before_action :authenticate_user!
  before_action :load_project, only: [:new, :create]
  before_action :load_user, only: [:new, :create]
  before_action :build_contribution, only: :new
  before_action :build_contribution_from_params, only: :create

  # Checks if the project is not orphan. It is only a security check.
  # FUTURE: Do some critical action here
  before_action :check_orphan_project, only: [:new, :create]

  # Project owner cannot contribute
  before_action :check_project_owner, only: [:new, :create]

  # To capture user's PAN and address details (Proceed if not verified, but display message)
  before_action :check_user_details, only: [:new, :create]

  # To make sure project end date has not expired
  before_action :check_project_end_date, only: [:new, :create]

  # To make sure no contributions are accepted if project state is invalid
  before_action :check_project_state, only: [:new, :create]

  # To make sure amount being contributed meets the project's minimum criteria
  before_action :check_minimum_amount, only: [:new, :create]

  # No need for more contributions if amount has been completely collected
  before_action :check_if_more_contribution_required, only: [:new, :create]

  def index; end

  def new; end

  def show
    @contribution = Contribution.find_by(id: params[:id])
    @transaction = @contribution.transactions.where(success: true).first
    pdf = ContributionPDF.new(@contribution, @transaction)
    respond_to do |format|
      format.pdf { send_data pdf.render, filename: 'invoice.pdf', type: 'application/pdf', disposition: 'inline' }
      format.html { render :show }
    end
  end

  def create
    if(@contribution.save)
      if(@contribution.purchase)
        ContributionMailer.payment_success(@contribution, @contribution.current_transaction).deliver
        render :success
      else
        @transaction = @contribution.current_transaction
        flash[:alert] = "Your contribution has not been accepted due to following reason: <br />#{ @transaction.message }".html_safe
        redirect_to project_path(@project)
      end
    else
      flash[:alert] = "Your contribution has not been accepted due to following reason: <br />#{ @contribution.errors[:base].join('. ') }".html_safe
      render :new
    end
  end

  protected

    def contribution_params
      params.require(:contribution).permit(:amount, :project_id, :user_id, :brand, :card_number, :card_verification, :card_expires_on)
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

    def build_contribution_from_params
      @contribution = @project.contributions.build(contribution_params)
      @contribution.user_id = @user.id
      @contribution.ip_address = request.remote_ip
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

    def check_minimum_amount
      if @contribution.amount < @project.min_amount_per_contribution 
        flash[:alert] = I18n.t :no_project_min_amount, scope: [:contributions, :errors]
        render :new
      end
    end

    def check_if_more_contribution_required
      if @project.amount_required <= @project.collected_amount
        flash[:alert] = I18n.t :project_amount_collected, scope: [:contributions, :errors]
        redirect_to root_path
      end
    end    
end
