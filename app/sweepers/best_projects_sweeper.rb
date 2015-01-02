class BestProjectsSweeper < ActionController::Caching::BestProjectsSweeper
  observe Project

  # Currently this expire is not called from anywhere as we have kept the window for cache for 30 minutes
  # In case we do want to expire the cache, we can call this method
  def expire_cache
    expire_fragment 'our_best_projects'
  end

end
