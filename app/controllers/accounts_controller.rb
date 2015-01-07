class AccountsController < ApplicationController
  include AddressesFormHelper, UserHelper

  before_action :store_location
  before_action :authenticate_user!
  before_action :set_account, only: [:edit, :update, :upload_pan_card_image, :upload_primary_address_proof, :upload_current_address_proof]
  before_action :set_user, only: [:update_pan_details, :update_address_details, :update_incomplete_details]

  def edit
    build_max_n_addresses(@user, 2)
  end

  def update
    respond_to do |format|
      if @user.update(account_params)
        format.html { redirect_to edit_account_path(@user) + '#user_address', notice: 'Your account has successfully been updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def upload_pan_card_image
    if(@user.update(pan_card_copy: params[:user][:pan_card_copy]))
      render json: { 
                  message: 'success', 
                  filename: @user.pan_card_copy 
                }, status: 200
    else
      render json: { error: @user.errors.full_messages.join(',') }, status: :bad_request
    end
  end

  def upload_primary_address_proof
    if @user.addresses.primary_address
      if(@user.addresses.primary_address.update(address_proof: params[:address][:address_proof]))
        render json: { 
                  message: 'success', 
                  filename: @user.addresses.primary_address.address_proof
                }, status: 200
      else
        render json: { error: @user.errors.full_messages.join(',') }, status: :bad_request
      end
    else
      render json: { error: 'Please provide address details first' }, status: :bad_request
    end
  end

  def upload_current_address_proof
    if @user.addresses.current_address
      if(@user.addresses.current_address.update(address_proof: params[:address][:address_proof]))
        render json: { 
                  message: 'success', 
                  filename: @user.addresses.current_address.address_proof 
                }, status: 200
      else
        render json: { error: @user.errors.full_messages.join(',') }, status: :bad_request
      end
    else
      render json: { error: 'Please provide address details first' }, status: :bad_request
    end
  end

  def update_pan_details
    render 'update_pan_details'
  end

  def update_address_details
    build_max_n_addresses(@user, 2)
    render :update_address_details
  end

  def update_incomplete_details
    respond_to do |format|
      if @user.update(account_params)
        check_user_details_and_redirect(format, @user)
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @user = current_user || User.find(params[:id])

      rescue ActiveRecord::RecordNotFound
        redirect_to root_path, alert: 'Cannot find the user in our system.'
    end

    def set_user
      @user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white
    # list through.
    def account_params
      params.require(:user).permit(:first_name, :last_name, :phone_number, :pan_card, :pan_card_copy, addresses_attributes: [:id, :city, :full_address, :primary, :country, :state, :pincode, :address_proof])
    end

end
