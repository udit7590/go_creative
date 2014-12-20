class AccountsController < ApplicationController
  include AddressesFormHelper

  before_action :authenticate_user!
  before_action :set_account, only: [:edit, :update, :upload_pan_card_image, :upload_address_proof]
  before_action :delete_proofs_if_address_pan_changed, only: :update

  def edit
    build_max_n_addresses(@user, 2)
  end

  def update
    respond_to do |format|
      if @user.update(account_params)
        format.html { redirect_to action: :edit, notice: 'Your account has successfully been updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end

  # If a user sends more than two address records
  rescue ActiveRecord::NestedAttributes::TooManyRecords
    flash[:alert] = 'You can only have two addresses.'
    redirect_to action: :edit
  end

  def upload_pan_card_image
    if(@user.update(pan_card_copy: params[:file]))
      render json: { message: 'success' }, status: 200
    else
      render json: { error: @user.errors.full_messages.join(',') }, status: 400
    end
  end

  def upload_address_proof
    if @user.addresses.primary_address
      if(@user.addresses.primary_address.update(address_proof: params[:file]))
        render json: { message: 'success' }, status: 200
      else
        render json: { error: @user.errors.full_messages.join(',') }, status: 400
      end
    else
      render json: { error: 'Please provide address details first'}, status: 400
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_account
      @user = current_user || User.find(params[:id])

    rescue ActiveRecord::RecordNotFound
      redirect_to root_path, alert: 'Cannot find the user in our system.'
    end

    # Never trust parameters from the scary internet, only allow the white
    # list through.
    def account_params
      params.require(:user).permit(:first_name, :last_name, :phone_number, :pan_card, addresses_attributes: [:id, :city, :full_address, :primary, :country, :state, :pincode])
    end

    def delete_proofs_if_address_pan_changed
      if(params[:user][:pan_card])
        if params[:user][:pan_card] != @user.pan_card
          @user.pan_card_copy.clear
        end
      elsif (params[:user][:addresses_attributes])
        if user_primary_address = @user.addresses.primary_address
          params[:user][:addresses_attributes].each_pair do |key, address|
            if address[:primary] && Address.new(address) == user_primary_address
              user_primary_address.address_proof.clear
            end
          end
        end
      end
    end

end
