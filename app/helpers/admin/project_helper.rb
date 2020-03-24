module Admin::ProjectHelper
  def publish_button_path(is_published, project)
    is_published ? admin_project_unpublish_path(project) : admin_project_publish_path(project)
  end

  def current_action_name(params)
    params[:action]
  end

end
