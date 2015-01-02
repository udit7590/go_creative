module Admin
  class DashboardController < ApplicationController
    layout 'dashboard'
    before_action :authenticate_admin_user!
  end
end
