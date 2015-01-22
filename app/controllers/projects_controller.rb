class ProjectsController < ApplicationController
  include UserHelper

  before_action :store_location
  before_action :authenticate_user!, except: [:index, :show, :charity, :investment, :load_more, :sort, :completed]
  before_action :initialize_project, only: [:new, :create]
  before_action :only_allow_xhr, only: :update_description

  # Loads the project based on ID. Make sure project owner is the currently logged in user
  # in case of edit/update 
  before_action :load_project, only: [:show, :edit, :update, :destroy, :update_description]

  # Checks if the project is not orphan. It is only a security check.
  # FUTURE: Do some critical action here
  before_action :check_orphan_project, only: [:show, :new, :edit, :create, :update, :update_description]

  # Check user is project owner when editing/ updating
  before_action :check_project_owner, only: [:edit, :update, :update_description]

  # Check if the project is in a valid state (> Published)
  before_action :verify_project_approved_or_owner, only: :show

  # To make sure user cannot edit critical details after project has been published
  # Makes sure project is in valid state before edit/update]
  before_action :check_if_published, only: [:edit, :update, :update_description]

  # To check if any sorting parameters are provided
  before_action :check_sorting_or_filtering_details_and_load_projects, only: :index


  def new
    @project.images.build
  end

  def create
    respond_to do |format|
      @project = current_user.projects.build(project_params)
      if @project.save
        check_user_details_and_redirect(format, @user, @project)
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
      @comments = @project.comments.order_by_date.deleted(false)
    else
      @comments = @project.comments.latest.visible_to_all(true)
    end
    @comment_count = @comments.deleted(false).count
  end

  def update
    respond_to do |format|
      if @project.update(project_params)
        flash[:notice] = t :project_edited, scope: [:projects, :views]
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

  #JSON
  def update_description
    if @project.update(description: params[:description])
      render json: { message: 'success' }
    else
      render json: { error: true }, status: 422
    end

  end

  # ---------------------------------------------------------------------------------
  # --------------------------- SECTION FOR PROJECTS PUBLIC VIEW --------------------
  # ---------------------------------------------------------------------------------

  # HTML request for listing and JSON for sorting and filtering
  def index
    @page_title = 'Projects'
    respond_to do |format|
      format.html { render :all } 
      format.json { render :load }
    end
  end

  def completed
    @projects = Project.successful.page(1)
    @page_title = 'Completed Projects'
    render :completed
  end

  def charity
    @projects = Project.recent_published_charity.page(1)
    @page_title = 'Charity Projects'
    render :all
  end

  def investment
    @projects = Project.recent_published_investment.page(1)
    @page_title = 'Investment Projects'
    render :all
  end

  def load_more
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
        respond_to do |format|
          format.html do 
            flash[:alert] = t :no_project, scope: [:projects, :views]
            redirect_to root_path
          end
          format.json { render json: { error: true, message: 'Cannot find any such project.' }, status: 422 }
        end
      end
    end

    def check_orphan_project
      unless @project.user_id
        respond_to do |format|
          format.html do 
            flash[:alert] = t :orphan_project, scope: [:projects, :views]
            redirect_to controller: :home, action: :index 
          end
          format.json { render json: { error: true, message: 'The project is no longer available.' }, status: 422 }
        end
      end
    end

    def check_project_owner
      unless @project.owner?(current_user)
        respond_to do |format|
          format.html { redirect_to root_path, alert: (t :not_project_owner, scope: [:projects, :update]) }
          format.json { render json: { error: true, message: 'You are not the project owner.' }, status: 422 }
        end
        
      end
    end

    def check_if_published
      if @project.published?
        respond_to do |format|
          format.html do 
            flash[:alert] = t :cannot_edit_published, scope: [:projects, :update]
            redirect_to action: :show
          end
          format.json { render json: { error: true, message: 'The project is no longer editable.' }, status: 422 }
        end
      end
    end

    def verify_project_approved_or_owner
      unless(@project.can_be_accessed_by?(current_user))
        redirect_to root_path, alert: (t :no_project, scope: [:projects, :views])
      end
    end

    def only_allow_xhr
      unless request.xhr?
        respond_to do |format|
          format.json { render json: { error: true, message: 'This action is only available on ajax requests.' }, status: 422 }
          format.html { head :bad_request }
        end
      end
    end

    def check_sorting_or_filtering_details_and_load_projects
      if params[:sort_by]
        @projects = Project.sort_by(params[:sort_by].try(:to_sym), params[:order_by].try(:to_sym)).page(1)
      elsif params[:filter_by]
        @projects = Project.successful.filter_by(params[:filter_by].try(:to_sym), params[:order_by].try(:to_sym)).page(1)
      else
        @projects = Project.recent_published.page(1)
      end
      @is_more_available = @projects.length == Project::INITIAL_PROJECT_DISPLAY_LIMIT
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
