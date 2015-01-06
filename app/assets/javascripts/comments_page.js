var CommentsPage = (function() {

  function CommentsPage(commentsContainer, formContainer, loadMoreButton) {
    this.$commentsContainer = commentsContainer;
    this.$formContainer = formContainer;
    this.$loadMoreButton = loadMoreButton;
  }

  CommentsPage.prototype.bindEventsForAddComment = function() {
    var _this = this,
        $commentForm = this.$formContainer.find('form'),
        $addCommentButton = this.$formContainer.find('.add-comment'),
        $commentList = null;

    $addCommentButton.click(function() {
      var $this = $(this),
          serializedHash = {};

      $($commentForm.serializeArray()).each(function(index, obj) { 
        serializedHash[obj['name']] = obj['value'];
      });

      if($this.data('admin')) {
        $commentList = _this.$commentsContainer.children('tbody');
      } else {
        $commentList = _this.$commentsContainer.children('ul');
      }

      if(serializedHash['comment[description]'].length < 3) {
        alert('Please enter at least 3 characters in your comment.');
        _this.$formContainer.find('textarea').focus();
        return;
      }
      this.disabled = true;
      _this.sendRequestToAddComment($commentForm.attr('action'), serializedHash, this, $commentList);
    });
  };

  CommentsPage.prototype.sendRequestToAddComment = function(path, data, button, commentList) {
    var _this = this;
    $.getJSON(path, { data: data })
     .done(function(jsonData) {
        var error = jsonData
        if(!jsonData['error'])
        //Load the comment in the view
        ContentLoader.loadContentInExistingList(commentList, jsonData['comment'], { template: Comment.template, prepend: true });

        //Clear the form
        _this.$formContainer.find('textarea').val('');
        
        //Scroll to the added comment
        $('html, body').animate({
            scrollTop: _this.$commentsContainer.offset().top + 'px'
        }, 'slow');
     })
     .always(function() {
        button.disabled = false;
     });
  };

  CommentsPage.prototype.bindClickEventForLoadMoreButton= function() {
    if(this.$loadMoreButton.length) {
      var _this = this;
      this.$loadMoreButton.click(function() {
        var $this = $(this),
            formData = { page: ($this.data('page') + 1) };
        
        if($this.data('admin')) {
          $commentList = _this.$commentsContainer.children('tbody');
          formData['admin'] = true;
        } else {
          $commentList = _this.$commentsContainer.children('ul');
        }

        _this.sendRequestToLoadMore($this.attr('path'), formData, $commentList);
      });
    }

  };

  CommentsPage.prototype.sendRequestToLoadMore = function(path, data, commentList) {
    var _this = this;
    $.getJSON(path, data)
     .done(function(jsonData) {

        //Load the comments on the page
        ContentLoader.loadContentInExistingList(commentList, jsonData['comments'], { template: Comment.template });

        //Remove Load more button if no more comments
        if(!jsonData['is_more_comments_available']) {
          _this.$loadMoreButton.remove();
        } else {
          _this.$loadMoreButton.data('page', page);
        }
    });
  };

  //Return the class
  return CommentsPage;
})();
