class AccountsController < ApplicationController
  include AddressesFormHelper, UserHelper

  # To store the previous accessed URL
  before_action :store_location

  # All users need to be authenticated to access their account details 
  # except for public profile view
  before_action :authenticate_user!, except: :show

  # Just sets the user instance variable as current user
  before_action :set_user, except: :show
  before_action :load_user, only: :show

  before_action :load_project, only: :update_incomplete_details

  before_action :check_current_address, only: :upload_current_address_proof
  before_action :check_primary_address, only: :upload_primary_address_proof

  def show
    @projects = @user.profile_projects
  end

  def edit
    build_max_n_addresses(@user, 2)
  end

  def update
    respond_to do |format|
      if @user.update(account_params)
        format.html { redirect_to (edit_account_path(anchor: params[:page].to_s)), notice: (I18n.t :details_updated, scope: [:account, :update]) }
        format.json { head :no_content }
      else
        format.html { render action: :edit, status: :bad_request }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # ---------------------------------------------------------------------------------
  # SECTION FOR ACTIONS WHEN USER CREATES PROJECT BUT HIS DETAILS ARE INCOMPLETE
  # ---------------------------------------------------------------------------------
  def update_pan_details
    render :update_pan_details
  end

  def update_address_details
    build_max_n_addresses(@user, 2)
    render :update_address_details
  end

  def update_incomplete_details
    if @user.update(account_params)
      check_user_details_and_redirect(@user, @project)
    else
      render action: :edit, status: :bad_request
    end
  end

  # ---------------------------------------------------------------------------------
  # SECTION FOR ACTIONS TO UPLOAD PAN/ADDRESS PROOFS BY AJAX
  # ---------------------------------------------------------------------------------

  def upload_pan_card_image
    if(@user.update(pan_card_copy: params[:user][:pan_card_copy]))
      render json: { message: 'success', filename: @user.pan_card_copy }, status: 200
    else
      render json: { error: @user.errors.full_messages.join(',') }, status: :bad_request
    end
  end

  def upload_primary_address_proof
    if(@user.addresses.primary_address.update(address_proof: params[:address][:address_proof]))
      render json: { message: 'success', filename: @user.addresses.primary_address.address_proof }, status: 200
    else
      render json: { error: @user.errors.full_messages.join(',') }, status: :bad_request
    end
  end

  def upload_current_address_proof
    if(@user.addresses.current_address.update(address_proof: params[:address][:address_proof]))
      render json: { message: 'success', filename: @user.addresses.current_address.address_proof }, status: 200
    else
      render json: { error: @user.errors.full_messages.join(',') }, status: :bad_request
    end
  end

  def edit_profile_picture; end

  def upload_profile_picture
    if(@user.update(profile_picture: params[:user][:profile_picture]))
      render json: { message: 'success', filename: @user.profile_picture }, status: 200
    else
      render json: { error: @user.errors.full_messages.join(',') }, status: :bad_request
    end
  end

  private

    def load_project
      @project = Project.find_by(id: session[:process_project_id])
      unless @project
        flash[:alert] = I18n.t :invalid_session, scope: [:errors, :views]
        redirect_to root_path
      end
    end

    def account_params
      params.require(:user).permit(:first_name, :last_name, :phone_number, :profile_picture, :pan_card, :pan_card_copy, addresses_attributes: [:id, :city, :full_address, :primary, :country, :state, :pincode, :address_proof])
    end

    def set_user
      @user = current_user
    end

    def load_user
      @user = User.find_by(id: params[:id])
      unless @user
        redirect_to root_path, alert: (t :no_user, scope: [:account, :views])
      end
    end

    def check_current_address
      unless @user.addresses.current_address
        render json: { error: 'Please provide address details first' }, status: :bad_request
      end
    end

    def check_primary_address
      unless @user.addresses.primary_address
        render json: { error: 'Please provide address details first' }, status: :bad_request
      end
    end

end
