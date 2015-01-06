class Admin::ProjectsController < ::ApplicationController
  layout 'dashboard'

  before_action :authenticate_admin_user!
  before_action :load_project, only: [:publish, :unpublish]
  before_action :check_project_unpublished, only: [:publish]

  def index
    @projects = Project.all.order_by_creation.page(params[:page]).per(20)
  end

  def publish
    respond_to do |format|
      @project.verified_at = DateTime.current
      @project.admin_user_id = current_admin_user.id
      if @project.publish!
         format.js { render 'publish', locals: { is_published: true } }
        format.html { redirect_to action: :index }
      else
        format.js { render 'error_publish' }
      end
    end
  end

  def unpublish
    respond_to do |format|
      @project.verified_at = nil
      @project.admin_user_id = current_admin_user.id
      if @project.unpublish!
         format.js { render 'publish', locals: { is_published: false } }
        format.html { redirect_to action: :index }
      else
        format.js { render 'error_publish', locals: { errors: @project.errors.full_messages } }
      end
    end
  end

  protected

    def load_project
      @project = Project.find_by(id: params[:project_id])
      unless @project
        respond_to do |format|
          format.js { render 'error_publish', locals: { project: nil } }
        end
      end
    end

    def check_project_unpublished
      if @project.verified_at
        respond_to do |format|
          format.js { render 'error_publish', locals: { already_published: true } }
        end
      end
    end

end
