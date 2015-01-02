class HomeController < ApplicationController
  
  def index
    if Rails.cache.read('our_best_projects')
      @projects = YAML.load(Rails.cache.read('our_best_projects'))
    else
      @projects = Project.best_projects
      Rails.cache.write('our_best_projects', @projects.to_yaml, expires_in: 2.minutes)
    end
  end

end
