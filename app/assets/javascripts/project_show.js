$(document).ready(function () {
    
  //set a custom width and height
  var $embeddedVideo = $('#embeddedVideo'),
      videoObject = new EmbedVideo($embeddedVideo.data('src'), { width: 770, height: 400 }),
      commentsPage = new CommentsPage($('section.comments'), $('.comment-form-container'), $('#comments_load_more_button')),
      editMode = false,
      $summerNote;
  
  $embeddedVideo.html(videoObject.generateEmbedTag());

  commentsPage.bindEventsForAddComment();
  commentsPage.bindClickEventForLoadMoreButton();

  $('.carousel').carousel({
    interval: 5000
  });

  //To allow in place editing of description
  $('#editDescription').click(function() {
    var $this = $(this);

    if(editMode == false) {
     $summerNote = $('#descriptionEditable').summernote({
        airPopover: [
          ['style', ['style']],
          ['font', ['bold', 'italic', 'underline', 'clear']],
          ['fontname', ['fontname']],
          ['color', ['color']],
          ['para', ['ul', 'ol', 'paragraph']],
          ['table', ['table']]
        ],
        styleTags: ['p', 'blockquote', 'h1', 'h2', 'h3', 'h4', 'h5'],
        airMode: true,
        focus: true
      });
      $this.text('Save');
      editMode = true;

    } else {
      $.loader({
        className:"blue-with-image-2",
        content:''
      });

      $.getJSON($this.data('path'), { description: $summerNote.code() })
      .error(function() {
        alert(jsonData['message']);
      })
      .always(function() {
        $.loader('close');
        $this.text('Edit');
        $summerNote.destroy();
        $summerNote.attr('id', 'descriptionEditable');
        editMode = false;
      });
    }
  });

  //Initialize Gallery
  $("#project-gallery").PikaChoose();

});