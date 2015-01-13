module UserHelper

  # Checks if details of the user are complete and redirect accordingly.
  # Takes format argument to redirect based on requested format.
  def check_user_details_and_redirect(format, user)
    unless user.complete?
      missing_page = (user.missing_info_page == :missing_pan) ? :update_pan_details : :update_address_details
      missing_message = (user.missing_info_page == :missing_pan) ? :pan_details_incomplete : :address_details_incomplete
      flash[:alert] = I18n.t missing_message, scope: [:projects, :views]
      format.html { redirect_to controller: :accounts, action: missing_page }
    else
      flash[:notice] = I18n.t :project_created, scope: [:projects, :views]
      format.html { redirect_to project_path(@project) }
    end
    format.json { head :no_content }
  end

end
