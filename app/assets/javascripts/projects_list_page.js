var ProjectsListPage = (function() {

  function ProjectsListPage(projectsListContainer, loadMoreButton, sortButtons) {
    this.$projectsListContainer = projectsListContainer;
    this.$loadMoreButton = loadMoreButton;
    this.$sortButtons = sortButtons;
  }

  ProjectsListPage.prototype.bindClickEventForLoadMoreButton= function() {
    if(this.$loadMoreButton.length) {
      var _this = this;
      this.$loadMoreButton.click(function() {
        var $this = $(this),
            data = {
              for_action: $this.attr('for_action'),
              page: ($this.data('page') + 1),
              sort_by: $this.data('sort-by'),
              order_by: $this.data('order-by')
            };
        _this.sendRequestToLoadMore($this.attr('path'), data);
      });
    }

  };

  ProjectsListPage.prototype.sendRequestToLoadMore = function(path, data) {
    var _this = this;
    $.getJSON(path, data)
     .done(function(jsonData) {
        //Load the projects in the listing page before the load more button
        _this.$loadMoreButton.before(ProjectListing.buildFromJSON(jsonData['projects']));

        //Remove Load more button if no more projects
        if(!jsonData['is_more_projects_available']) {
          _this.$loadMoreButton.remove();
        } else {
          _this.$loadMoreButton.data('page', data['page']);
        }
    });
  };

  ProjectsListPage.prototype.bindClickEventForSortButton= function() {
    if(this.$sortButtons.length) {
      var _this = this;
      this.$sortButtons.click(function(e) {
        e.preventDefault();
        var $this = $(this),
            data = {
              sort_by: $this.data('sort-by'),
              order_by: $this.data('order-by')
            };
        _this.sendRequestToSort($this.data('path'), data);
      });
    }
  };

  ProjectsListPage.prototype.sendRequestToSort = function(path, data) {
    $.loader({
        className:"blue-with-image-2",
        content:''
    });
    var _this = this;
    $.getJSON(path, data)
     .done(function(jsonData) {
        $('.all-projects').html(ProjectListing.buildFromJSON(jsonData['projects']));

        if(jsonData['is_more_projects_available']) {
          _this.$loadMoreButton = $('<button>', { class: 'btn btn-block', id: 'projects_load_more_button', action: 'load_more', for_action: 'sort', path: '/projects/load_more' }).text('I want to see more projects').data('page', 1).data('sort_by', data['sort_by']).data('order_by', data['order_by']);
          $('.all-projects').append(_this.$loadMoreButton);
          _this.bindClickEventForLoadMoreButton();
        }
    }).always(function() {
      $.loader('close');
    });
  };

  //Return the class
  return ProjectsListPage;
})();

$(document).ready(function() {
  var projectsListPage = new ProjectsListPage($('.row.all-projects'), $('#projects_load_more_button'), $('.sort_by'));
  
  projectsListPage.bindClickEventForLoadMoreButton();
  projectsListPage.bindClickEventForSortButton();

});
