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
        flash[:notice] = 'Your project is created.'
        format.html { redirect_to controller: :home, action: :index }
        format.json { head :no_content }
      else
        @project = @project.becomes!(Project)

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
      params.require(:project).permit(:type, :title, :description, :end_date, :amount_required, :video_link, images_attributes: [:id, :image], legal_documents_attributes: [:id, :image])
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

end
