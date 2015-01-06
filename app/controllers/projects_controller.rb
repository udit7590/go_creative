class ProjectsController < ApplicationController
  include UserHelper

  before_action :store_location
  before_action :authenticate_user!, except: [:index, :show, :charity_projects, :investment_projects]
  before_action :verify_project_approved_or_owner, only: :show
  before_action :initialize_project, only: [:new, :create]
  before_action :load_project, only: [:show, :edit, :update, :destroy]
  before_action :check_if_published, only: [:edit, :update]

  def new
    @project.images.build
  end

  def create
    respond_to do |format|
      @project = current_user.projects.build(project_params)
      if @project.save
        check_project_user_details_and_redirect(format)
      else
        @project = @project.becomes!(Project)
        @project.type = params[:project][:type]
        
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  def show
    @comments = @project.comments.latest
    @comment_count = @project.comments.deleted(false).count
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

  # --------------------------- SECTION FOR PROJECTS PUBLIC VIEW --------------------
  # ---------------------------------------------------------------------------------
  def index
    @projects = Project.published_projects
    @page_title = 'Projects'
    render :all
  end

  def charity_projects
    @projects = Project.published_charity_projects
    @page_title = 'Charity Projects'
    render :all
  end

  def investment_projects
    @projects = Project.published_investment_projects
    @page_title = 'Investment Projects'
    render :all
  end

  def load_more_projects
    case params[:for_action]
    when 'charity_projects'
      @projects = Project.published_charity_projects(params[:page].to_i)
    when 'investment_projects'
      @projects = Project.published_investment_projects(params[:page].to_i)
    else
      @projects = Project.published_projects(params[:page].to_i)
    end
    # @projects = Project.public_send("published_#{ params[:for_action] }projects", params[:page].to_i)
    @is_more_available = @projects.length == Project::INITIAL_PROJECT_DISPLAY_LIMIT
    render 'load'
  end

  # ---------------------------------------------------------------------------------
  # ---------------------------------------------------------------------------------

  protected

    def initialize_project
      @user = current_user
      @project = @user.projects.build
    end

    def load_project
      @user = current_user
      @project = Project.find_by(id: params[:id])
    end

    def project_params
      params.require(:project).permit(:type, :title, :description, :end_date, :amount_required, :video_link, :min_amount_per_contribution, :project_picture, images_attributes: [:id, :image], legal_documents_attributes: [:id, :image])
    end

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

    # Checks if details of the user are complete and redirect accordingly.
    # Takes format argument to redirect based on requested format.
    def check_project_user_details_and_redirect(format)
      @user = @project.user
      unless @user
        format.html { redirect_to controller: :home, action: :index, alert: 'This project has been deleted.' }
      end

      check_user_details_and_redirect(format, @user)

    end

    def verify_project_approved_or_owner
      @user = current_user
      @project = Project.find_by(id: params[:id])
      unless(@project.user == current_user || @project.verified_at)
        redirect_to root_path, alert: 'Cannot find any such project'
      end
    end

    def check_if_published
      if @project.published?
        flash[:alert] = 'This project cannot be edited now'
        redirect_to action: :show
      end
    end

end
