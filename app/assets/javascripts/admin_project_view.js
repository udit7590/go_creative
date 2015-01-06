$(document).ready(function () {
    
  //set a custom width and height
  var commentsPage = new CommentsPage($('#projectComments'), $('.comment-form-container'), $('#comments_load_more_button'));

  Comment.template = '<script id="comment_listing_template" type="text/html"> \
    {{#.}} \
      <tr data-project-id="{{project.id}}" data-comment-id={{id}}> \
        <td>{{description}}</td> \
        <td>{{user.name}}</td> \
        <td>{{updated_at}}</td> \
        <td>{{abused_count}}</td> \
        <td>{{spam}}</td> \
        <td><a href="{{delete_path}}" data-method="{{delete_method}}" data-remote="true" data-confirm="Are you sure?" class="delete-comment"> <button>Delete</button></a></td> \
      </tr> \
    {{/.}} \
  </script>';
  
  commentsPage.bindEventsForAddComment();
  commentsPage.bindClickEventForLoadMoreButton();

});