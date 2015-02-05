class Admin::ContributionsController < ::ApplicationController
  layout 'dashboard'

  before_action :authenticate_admin_user!

  before_action :load_contribution, only: :transactions

  #JSON
  def transactions
    @transactions = @contribution.transactions
  end

  protected

    def load_contribution
      @contribution = Contribution.find(params[:contribution_id])
      render json: { error: 'Cannot find any such contribution' }, status: 422 unless @contribution
    end

end
