class Admin::ProjectsController < ::ApplicationController
  layout 'dashboard'

  before_action :authenticate_admin_user!
  before_action :load_project, only: [:show, :publish, :unpublish, :cancel]
  before_action :check_project_unpublished, only: [:publish]
  before_action :check_project_details, only: [:publish]
  before_action :check_user_details, only: :publish

  before_action :check_project_state, only: :cancel

  def index
    #FIXME_AB: I have not seen you using include or egarload. Please check you log and egarload data
    @projects = Project.all.order_by_creation.page(params[:page]).per(20)
    @filter = 'all'
  end

  def published
    @projects = Project.published.order_by_creation.page(params[:page]).per(20)
    render :index
  end

  def initial
    @projects = Project.created.order_by_creation.page(params[:page]).per(20)
    render :index
  end

  def show
    @comments = @project.comments.order_by_date
    @comment_count = @project.comments.deleted(false).count
    @contributors = @project.contributions.order(created_at: :desc)
  end

  def publish
    respond_to do |format|
      #FIXME_AB: We should set verified_at and admin_user_id in the callback of publish!
      @project.verified_at = DateTime.current
      @project.admin_user_id = current_admin_user.id
      if @project.publish!
        format.js { render 'publish', locals: { is_published: true } }
        format.html do
          flash[:notice] = 'Project has been successfully published'
          redirect_to action: :index 
        end
      else
        format.js { render 'error_publish' }
        format.html do
          flash[:alert] = 'Project not published.'
          redirect_to action: :index 
        end
      end
    end
  end

  def unpublish
    respond_to do |format|
      @project.verified_at = nil
      @project.admin_user_id = current_admin_user.id
      if @project.unpublish!
        format.js { render 'publish', locals: { is_published: false } }
        format.html do
          flash[:notice]= 'Project has been successfully unpublished'
          redirect_to action: :index
        end
      else
        format.js { render 'error_publish', locals: { project: nil, errors: @project.errors.full_messages } }
        format.html do
          flash[:alert] = @project.errors.full_messages
          redirect_to admin_project_path(params[:project_id])
        end
      end
    end
  end

  def cancel
    respond_to do |format|
      if @project.cancel!
        @success_message = 'The project is successfully cancelled'
        format.js { render 'cancel' }
        format.html do 
          flash[:notice] = @success_message
          redirect_to action: :index
        end
      else
        @error_message = @project.errors.full_messages
        format.js { render 'error_cancel' }
        format.html do 
          flash[:alert] = @error_message
          redirect_to admin_project_path(params[:project_id])
        end
      end
    end
  end

  protected

    def load_project
      @project = Project.find_by(id: (params[:project_id] || params[:id]))
      unless @project
        respond_to do |format|
          format.js { render 'error_publish', locals: { project: :not_found } }
          flash[:alert] = 'No such project found'
          format.html { redirect_to admin_root_path }
        end
      end
    end

    def check_project_unpublished
      if @project.published?
        respond_to do |format|
          format.js { render 'error_publish', locals: { project: :already_published } }
        end
      end
    end

    def check_project_details
      if @project.valid?
        unless @project.check_end_date
          respond_to do |format|
            format.js { render 'error_publish', locals: { project: :end_date_inapt } }
            format.html do 
              flash[:alert] = 'Cannot publish the project as end date is not appropriate.'
              redirect_to admin_project_path(params[:project_id])
            end
          end
        end
      else
        respond_to do |format|
          format.js { render 'error_publish', locals: { project: :project_invalid } }
          flash[:alert] = @project.errors.full_messages
          format.html { redirect_to action: :index }
        end
      end
    end

    def check_user_details
      unless @project.user.verified?
        respond_to do |format|
          format.js { render 'error_publish', locals: { project: :user_incomplete } }
          flash[:alert] = 'Cannot publish the project as user details are incomplete or not verified.'
          format.html { redirect_to admin_project_path(params[:project_id]) }
        end
      end
    end

    def check_project_state
      unless @project.cancelable?
        respond_to do |format|
          @error_message = 'Cannot cancel the project as project is successful, expired or already cancelled.'
          format.js { render 'error_cancel' }
          format.html do
            flash[:alert] = @error_message
            redirect_to admin_project_path(params[:project_id])
          end
        end
      end
    end

end
