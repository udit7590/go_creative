var ProjectsListPage = (function() {

  function ProjectsListPage(projectsListContainer, loadMoreButton) {
    this.$projectsListContainer = projectsListContainer;
    this.$loadMoreButton = loadMoreButton;
  }

  ProjectsListPage.prototype.bindClickEventForLoadMoreButton= function() {
    if(this.$loadMoreButton.length) {
      var _this = this;
      this.$loadMoreButton.click(function() {
        var $this = $(this);
        _this.sendRequestToLoadMore($this.attr('path'), $this.attr('for_action'), $this.data('page') + 1);
      });
    }

  };

  ProjectsListPage.prototype.sendRequestToLoadMore = function(path, action, page) {
    var _this = this;
    $.getJSON(path, { for_action: action, page: page })
     .done(function(jsonData) {

        //Load the projects in the listing page before the load more button
        _this.$loadMoreButton.before(ProjectListing.buildFromJSON(jsonData['projects']));

        //Remove Load more button if no more projects
        if(!jsonData['is_more_projects_available']) {
          _this.$loadMoreButton.remove();
        } else {
          _this.$loadMoreButton.data('page', page);
        }
    });
  };

  //Return the class
  return ProjectsListPage;
})();

$(document).ready(function() {
  var projectsListPage = new ProjectsListPage($('.row.all-projects'), $('#projects_load_more_button'));
  
  projectsListPage.bindClickEventForLoadMoreButton();

});
