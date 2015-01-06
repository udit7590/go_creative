class Admin::ProjectsController < ::ApplicationController
  layout 'dashboard'

  before_action :authenticate_admin_user!
  before_action :load_project, only: [:show, :publish, :unpublish]
  before_action :check_project_unpublished, only: [:publish]
  before_action :check_project_details, only: [:publish]
  before_action :check_user_details, only: :publish

  def index
    @projects = Project.all.order_by_creation.page(params[:page]).per(20)
  end

  def show
    @comments = @project.comments.order_by_date
    @comment_count = @project.comments.deleted(false).count
  end

  def publish
    respond_to do |format|
      @project.verified_at = DateTime.current
      @project.admin_user_id = current_admin_user.id
      if @project.publish!
        format.js { render 'publish', locals: { is_published: true } }
        flash[:notice]= 'Project published'
        format.html { redirect_to action: :index }
      else
        format.js { render 'error_publish' }
        flash[:alert] = 'Project not published.'
        format.html { redirect_to action: :index }
      end
    end
  end

  def unpublish
    respond_to do |format|
      @project.verified_at = nil
      @project.admin_user_id = current_admin_user.id
      if @project.unpublish!
        format.js { render 'publish', locals: { is_published: false } }
        flash[:notice]= 'Project unpublished'
        format.html { redirect_to action: :index }
      else
        format.js { render 'error_publish', locals: { project: nil, errors: @project.errors.full_messages } }
        flash[:alert] = @project.errors.full_messages
        format.html { redirect_to admin_project_path(params[:project_id]) }
      end
    end
  end

  protected

    def load_project
      @project = Project.find_by(id: params[:project_id]) || Project.find_by(id: params[:id])
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
            flash[:alert] = 'Cannot publish the project as end date is not appropriate.'
            format.html { redirect_to admin_project_path(params[:project_id]) }
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

end
