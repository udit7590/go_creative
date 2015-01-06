$(document).ready(function () {
    
  //set a custom width and height
  var $embeddedVideo = $('#embeddedVideo'),
      videoObject = new EmbedVideo($embeddedVideo.data('src'), { width: 370, height: 207 });
  
  $embeddedVideo.html(videoObject.generateEmbedTag());

});