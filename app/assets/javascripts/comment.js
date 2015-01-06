var Comment = (function() {

  //FOR FUTURE REFERENCE: We can assign data attribute to our project listing
  //and initialize the ProjectListing object from each json object for that
  function Comment() {
    this.name = null;
    this.email = null;
    this.id = null;
    this.description = null;
  }

  Comment.buildFromJSON = function(jsonData) {
    
    var template = $(Comment.template).html();

    return $(Mustache.render(template, jsonData));
  };

  Comment.template = '<script id="comment_listing_template" type="text/html"> \
    {{#.}} \
      <li data-project-id="{{project.id}}" data-comment-id={{id}}> \
        <img src="/assets/img/user-avatar.jpg" /> \
        <span class="comment-name">{{user.name}}</span> \
        <span class="comment-date"> \
          {{updated_at}} | <a href="#">Report Abuse</a> \
          | <a href="{{delete_path}}" data-remote="true" data-confirm="Are you sure?" class="delete-comment"> Delete</a> \
        </span> \
        <div class="comment-content">{{description}}</div> \
      </li> \
    {{/.}} \
  </script>';
  
  //Return the class
  return Comment;
})();