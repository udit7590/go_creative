class HomeController < ApplicationController
  
  def index
    @popular_projects = Project.cached_popular
    @recent_projects = Project.cached_recent(Constants::PROJECT_HOME_PAGE_LIMIT, @popular_projects.collect(&:id))
    @completed_projects = Project.cached_completed
  end

end
