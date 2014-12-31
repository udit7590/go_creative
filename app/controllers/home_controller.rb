class HomeController < ApplicationController
  
  def index
    @projects = Rails.cache.fetch('our_best_products', expires_in: 30.minutes) do
      Project.best_projects
    end
  end

end
