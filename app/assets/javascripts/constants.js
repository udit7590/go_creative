const emailPattern = '^[-a-z0-9_+]+(\.?[-a-z0-9_+]+)*@[a-z0-9][-a-z0-9]*(\.?[-a-z0-9]+)*\.[a-z]{2,}$';
const passwordPattern = '.{8,128}';
const namePattern = '[A-z]{1,40}';
const minPasswordLength = 8;
const minNameLength = 1;
const videoProviders = ['youtube'];
const videoDomainMatchRegex = /^https:\/\/www\.youtube\.com\/watch\?v=([^\?\&\/]+)/;
const videoDomainMatchPattern = 'https:\\/\\/www\\.youtube\\.com\\/watch\\?v=([A-z0-9_]+)';

$(function() {
  var matchElements = '[data-pattern="email"],[data-pattern="password"],[data-pattern="name"],[data-embed="video"],[data-uploader="single"],[data-animate="progress"]'
  $(matchElements).each(function() {
    var $this = $(this);
    if($this.data('pattern') == 'email') {
      $this.attr('pattern', emailPattern); 
    }
    if($this.data('pattern') == 'password') { 
      $this.attr('min', minPasswordLength); 
      $this.attr('pattern', passwordPattern);
      $this.attr('required', true);
    }
    if($this.data('pattern') == 'name') { 
      $this.attr('min', minNameLength); 
      $this.attr('pattern', namePattern);
    }
    if($this.data('embed') == 'video') {
      $this.attr('pattern', videoDomainMatchPattern);
      $this.attr('title', 'Video url must be from youtube.');
    }
    if($this.data('animate') == 'progress') {
      var width = $this.data('progress-complete') + '%';
      $this.css('width', width);
      $this.animate({width:width});
    }
    if($this.data('uploader') == 'single') {
      var $imagePreviewer = $('<div>', { class: 'image-uploader-container' })
                            .css('width', ($this.data('width') || '200'))
                            .css('height', $this.data('height') || '200')
                            .addClass('before-select');

      if($this.data('prev') != undefined) {
        var $lightboxImage = $('<a>', { href: $this.data('prev')})
                             .attr('data-lightbox', $this.data('prev'))
                             .html($('<img>', { src: $this.data('prev') }));

        $imagePreviewer.html($lightboxImage);
         $imagePreviewer.removeClass('before-select');
      }

      $this.before($imagePreviewer);

      $this.change(function(e) {
        var file = this.files[0],
            $this = $(this);
        $imagePreviewer.removeClass('before-select').removeClass('select-error');

        if (typeof FileReader !== "undefined" && (/image/i).test(file.type)) {
          var $lightboxImageContainer = $('<a>', { href: $this.data('prev')})
                                        .attr('data-lightbox', $this.data('prev')),
              $image = $('<img>');

          $this.prev('.image-uploader-container').html($lightboxImageContainer.html($image));
          reader = new FileReader();
          reader.onload = (function ($image) {
            return function (evt) {
              $image.attr('src', evt.target.result);
            };
          }($image));
          reader.readAsDataURL(file);
        } else {
          $this.prev('.image-uploader-container').html('Not an image file.');
          $imagePreviewer.addClass('select-error');
        }
      });
    }
  });

});
