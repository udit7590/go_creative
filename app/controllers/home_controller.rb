class HomeController < ApplicationController
  
  def index
    @recent_projects = Project.cached_recent
    @completed_projects = Project.cached_completed
    @popular_projects = Project.cached_popular(@recent_projects.collect(&:id))
  end

end
