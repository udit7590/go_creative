module Admin
  class DashboardController < ApplicationController
    layout 'dashboard'
    before_filter :authenticate_admin_user!
  end
end
