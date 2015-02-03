var AdminUserDetailsPage = (function() {

  function AdminUserDetailsPage(actions) {
    this.$actions = actions;
  }

  AdminUserDetailsPage.prototype.bindEventToLoadTransactions = function() {
    if(this.$actions.length) {
      this.$actions.click(function() {
        $.loader({
          className:"blue-with-image-2",
          content:''
        });
        var $this = $(this),
            data = { contribution_id: $this.data('contribution-id') },
            key = 'transactions_for_' + data['contribution_id'];

        $.getJSON($this.data('path'), data)
         .done(function(jsonData) {
            var template = $('#contribution_transactions_template').html(),
                renderedHtml = $(Mustache.render(template, jsonData));

            loadTransactionModal(renderedHtml, key);

        }).error(function(jsonData) {
          alert(jsonData['error'])
        })
         .always(function() {
          $.loader('close');
        });
      });
    }
  };

  // Section for private functions
  function loadTransactionModal(renderedHtml, key) {
    $('#transactionModal').html(renderedHtml);
    $('#contributionTransactionsModal').modal({
        backdrop : true,
        keyboard : true,
        show     : true
    });
    if(localStorage) {
      localStorage.setItem(key, renderedHtml);
    }
  }

  function checkAlreadyLoaded(key) {
    if(localStorage && localStorage[key]) {
      loadTransactionModal(localStorage[key], key);
      return true;
    }
    return false;
  }

  //Return the class
  return AdminUserDetailsPage;
})();

$(document).ready(function() {
  var adminUserDetailsPage = new AdminUserDetailsPage($('.transactions-detail'));
  adminUserDetailsPage.bindEventToLoadTransactions();
});
