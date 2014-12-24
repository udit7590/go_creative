class Admin::ProjectsController < ::ApplicationController
  layout 'dashboard'

  def index
    @projects = Project.all.projects_to_be_approved.page(params[:page]).per(20)
  end

end
