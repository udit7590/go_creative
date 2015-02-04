module UserConcern

  # Checks if details of the user are complete and redirect accordingly.
  # Takes format argument to redirect based on requested format.
  def check_user_details_and_redirect(user, project)
    unless user.complete?
      missing_page = (user.missing_info_page == :missing_pan) ? :update_pan_details : :update_address_details
      missing_message = (user.missing_info_page == :missing_pan) ? :pan_details_incomplete : :address_details_incomplete
      flash[:alert] = I18n.t missing_message, scope: [:projects, :views]
      redirect_to controller: :accounts, action: missing_page, flash: { project: project }
    else
      redirect_url = session[:request_url]
      if redirect_url
        flash[:notice] = I18n.t :details_updated, scope: [:contributions, :notice]
        redirect_to redirect_url
      else
        flash[:notice] = I18n.t :project_created, scope: [:projects, :views]
        redirect_to project_path(project)
      end
    end
  end

  def store_redirect_location(project, params, redirect_url)
    # store redirect url - this is needed for redirect to some page after filling out missing details.
    session[:request_url] = redirect_url
    session[:process_project_id] = project.id
    # session[:request_data] = params
  end

  def clear_redirect_location
    session[:request_url] = nil
    session[:process_project_id] = nil
    session[:request_data] = nil
  end

end
