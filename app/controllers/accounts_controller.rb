class AccountsController < ApplicationController
  include AddressesFormHelper

  before_action :authenticate_user!
  before_action :set_account, only: [:edit, :update, :upload_pan_card_image]

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
  end

  def upload_pan_card_image
    @user.pan_card_copy = params[:file]
    if(@user.save)
      render json: { message: "success", fileID: '1' }, :status => 200
    else
      render json: { error: @user.errors.full_messages.join(',')}, :status => 400
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
      params.require(:user).permit(:first_name, :last_name, :phone_number, :addresses, :pan_card)
    end

end
