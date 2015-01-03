class ProjectsDisplayController < ApplicationController

  def all
    @projects = Project.published_projects
    @page_title = 'Projects'
  end

  def charity
    @projects = Project.published_charity_projects
    @page_title = 'Charity Projects'
    render 'all'
  end

  def investment
    @projects = Project.published_investment_projects
    @page_title = 'Investment Projects'
    render 'all'
  end

  def load_more
    case params[:for_action]
    when 'charity'
      @projects = Project.published_charity_projects(params[:page].to_i)
    when 'investment'
      @projects = Project.published_investment_projects(params[:page].to_i)
    else
      @projects = Project.published_projects(params[:page].to_i)
    end
    @is_more_available = @projects.length == Project::INITIAL_PROJECT_DISPLAY_LIMIT
    render 'load'
  end

end
