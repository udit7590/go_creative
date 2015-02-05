var AdminProjectsPage = (function() {

  function AdminProjectsPage(filterContainer, actions) {
    this.$filterContainer = filterContainer;
    this.$actions = actions;
  }

  AdminProjectsPage.prototype.bindEventForFilter = function() {
    if(this.$filterContainer.length) {
      this.$filterContainer.find('input[type=radio]').change(function() {
        var $this = $(this);
        $(location).attr('href',$this.data('path'));
      });
    }
  };

  AdminProjectsPage.prototype.loaderForAjaxActions = function() {
    if(this.$actions.length) {
      this.$actions.click(function() {
        var confirmation = confirm($(this).data('confirm-message'));
        if(confirmation) {
          $.loader({
            className:"blue-with-image-2",
            content:''
          });
        }
      });
    }
  };

  //Return the class
  return AdminProjectsPage;
})();

$(document).ready(function() {
  var adminProjectsPage = new AdminProjectsPage($('#projects-filter'), $('.project-actions'));

  adminProjectsPage.bindEventForFilter();
  adminProjectsPage.loaderForAjaxActions();

});
