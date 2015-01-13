class HomeController < ApplicationController
  
  def index
    @recent_projects = Project.cached_recent
    @completed_projects = Project.cached_completed(@recent_projects.collect(&:id))
    @popular_projects = Project.cached_popular
  end

end
