class ProjectsController < ApplicationController
  include UserHelper

  before_action :store_location
  before_action :authenticate_user!, except: [:index, :show, :charity_projects, :investment_projects, :load_more_projects, :sort_projects]
  before_action :initialize_project, only: [:new, :create]

  # Loads the project based on ID. Make sure project owner is the currently logged in user
  # in case of edit/update 
  before_action :load_project, only: [:show, :edit, :update, :destroy]

  # Checks if the project is not orphan. It is only a security check.
  # FUTURE: Do some critical action here
  before_action :check_orphan_project, only: [:show, :new, :edit, :create, :update]

  # Check user is project owner when editing/ updating
  before_action :check_project_owner, only: [:edit, :update]

  # Check if the project is in a valid state (> Published)
  before_action :verify_project_approved_or_owner, only: :show

  # To make sure user cannot edit critical details after project has been published
  # Makes sure project is in valid state before edit/update]
  before_action :check_if_published, only: [:edit, :update]

  def new
    @project.images.build
  end

  def create
    respond_to do |format|
      @project = current_user.projects.build(project_params)
      if @project.save
        check_user_details_and_redirect(format, @user)
      else
        @project = @project.becomes!(Project)
        @project.type = params[:project][:type]
        
        format.html { render action: 'new', status: :bad_request }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    #FIXME_AB: refactor it. @project.comments written three times
    if current_user && @project.user_id == current_user.id
      @comments = @project.comments.order_by_date.where(deleted: false)
    else
      @comments = @project.comments.latest.visible_to_all(true)
    end
    @comment_count = @comments.deleted(false).count
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        flash[:notice] = I18n.t :project_edited, scope: [:projects, :views]
        format.html { redirect_to action: :show }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    #TODO: Delete the project
    render text: 'TODO'
  end

  def user_projects
    @user = current_user
    @projects = @user.projects
    render 'user_projects'
  end

  # ---------------------------------------------------------------------------------
  # --------------------------- SECTION FOR PROJECTS PUBLIC VIEW --------------------
  # ---------------------------------------------------------------------------------

  def index
    @projects = Project.recent_published.page(1)
    @page_title = 'Projects'
    render :all
  end

  def charity_projects
    @projects = Project.recent_published_charity.page(1)
    @page_title = 'Charity Projects'
    render :all
  end

  def investment_projects
    @projects = Project.recent_published_investment.page(1)
    @page_title = 'Investment Projects'
    render :all
  end

  def load_more_projects
    #FIXME_AB: There is a better way to write same code so that you done repeat @project and Project many times
    case params[:for_action]
    when 'charity_projects'
      @projects = Project.recent_published_charity.page(params[:page].to_i)
    when 'investment_projects'
      @projects = Project.recent_published_investment.page(params[:page].to_i)
    when 'sort'
      @projects = Project.sort_by(params[:sort_by].try(:to_sym), params[:order_by].try(:to_sym)).page(params[:page].to_i)
    else
      @projects = Project.recent_published.page(params[:page].to_i)
    end
    # @projects = Project.public_send("published_#{ params[:for_action] }projects", params[:page].to_i)
    @is_more_available = @projects.length == Project::INITIAL_PROJECT_DISPLAY_LIMIT
    render 'load'
  end

  # ---------------------------------------------------------------------------------
  # --------------------------- SECTION FOR SORTING PROJECTS ------------------------
  # ---------------------------------------------------------------------------------

  #JSON Request
  def sort_projects
    @projects = Project.sort_by(params[:sort_by].try(:to_sym), params[:order_by].try(:to_sym)).page(1)
    @is_more_available = @projects.length == Project::INITIAL_PROJECT_DISPLAY_LIMIT
    render :load
  end

  protected

    # ---------------------------------------------------------------------------------
    # SECTION FOR FILTERS
    # ---------------------------------------------------------------------------------

    def project_params
      params.require(:project).permit(:type, :title, :description, :end_date, :amount_required, :video_link, :min_amount_per_contribution, :project_picture, images_attributes: [:id, :image], legal_documents_attributes: [:id, :image])
    end

    def initialize_project
      @user = current_user
      @project = @user.projects.build
    end

    def load_project
      @user = current_user
      @project = Project.find_by(id: (params[:project_id] || params[:id]))
      unless @project
        flash[:alert] = I18n.t :no_project, scope: [:projects, :views]
        redirect_to controller: :home, action: :index
      end
    end

    def check_orphan_project
      unless @project.user_id
        flash[:alert] = I18n.t :orphan_project, scope: [:projects, :views]
        redirect_to controller: :home, action: :index
      end
    end

    def check_project_owner
      unless(@project.user_id == current_user.id)
        redirect_to root_path, alert: (I18n.t :not_project_owner, scope: [:projects, :update])
      end
    end

    def check_if_published
      if @project.published?
        flash[:alert] = I18n.t :cannot_edit_published, scope: [:projects, :update]
        redirect_to action: :show
      end
    end

    #FIXME_AB: project.can_be_accessed_by?(current_user)
    def verify_project_approved_or_owner
      unless(@project.published? || @project.user_id == current_user.try(:id))
        redirect_to root_path, alert: (I18n.t :no_project, scope: [:projects, :views])
      end
    end

    # ---------------------------------------------------------------------------------
    # SECTION FOR UTILITY METHODS
    # ---------------------------------------------------------------------------------

    def upload_images_and_documents
      if params[:project][:images]
        params[:project][:images].each do |project_image|
          @project.images.create(image: project_image, document: false)
        end
      end

      if params[:project][:legal_documents]
        params[:project][:legal_documents].each do |project_doc|
          @project.images.create(image: project_doc, document: true)
        end
      end
    end

end
