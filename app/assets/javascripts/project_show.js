$(document).ready(function () {
    
  //set a custom width and height
  var $embeddedVideo = $('#embeddedVideo'),
      videoObject = new EmbedVideo($embeddedVideo.data('src'), { width: 370, height: 207 }),
      commentsPage = new CommentsPage($('section.comments'), $('.comment-form-container'), $('#comments_load_more_button'));;
  
  $embeddedVideo.html(videoObject.generateEmbedTag());

  commentsPage.bindEventsForAddComment();
  commentsPage.bindClickEventForLoadMoreButton();

});