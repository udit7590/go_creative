class ProjectsController < ApplicationController

  before_action :store_location
  before_action :authenticate_user!, only: [:new, :create, :edit, :update, :delete]
  before_action :load_project, only: [:new, :create]

  def new
    @project.images.build
  end

  def create
    respond_to do |format|
      @project = current_user.projects.build(project_params)
      if @project.save
        check_user_details_and_redirect(format)
      else
        @project = @project.becomes!(Project)
        @project.type = params[:project][:type]
        
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end
  
  protected

    def load_project
      @user = current_user
      @project = @user.projects.build
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
    def check_user_details_and_redirect(format)
      @user = @project.user
      unless @user
        format.html { redirect_to controller: :home, action: :index, alert: 'This project has been deleted.' }
      end

      unless @user.complete?
        flash[:notice] = I18n.t :pan_details_incomplete, scope: [:projects, :views]
        missing_page = (@user.missing_info_page == :missing_pan) ? :pan_details_incomplete : :address_details_incomplete
        format.html { redirect_to controller: :accounts, action: missing_page }
      else
        flash[:notice] = I18n.t :project_created, scope: [:projects, :views]
        format.html { redirect_to controller: :home, action: :index }
      end
      format.json { head :no_content }
    end

end
