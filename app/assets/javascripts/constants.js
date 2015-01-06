const emailPattern = '^[-a-z0-9_+]+(\.?[-a-z0-9_+]+)*@[a-z0-9][-a-z0-9]*(\.?[-a-z0-9]+)*\.[a-z]{2,}$';
const passwordPattern = '.{8,128}';
const namePattern = '[A-z]{1,40}';
const minPasswordLength = 8;
const minNameLength = 1;
const videoProviders = ['youtube'];
const videoDomainMatchRegex = /^https:\/\/www\.youtube\.com\/watch\?v=([^\?\&\/]+)/;
const videoDomainMatchPattern = 'https:\\/\\/www\\.youtube\\.com\\/watch\\?v=([A-z0-9_]+)';

$(function() {
  var matchElements = '[data-pattern="email"],[data-pattern="password"],[data-pattern="name"],[data-embed="video"]'
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
  });

});
  
