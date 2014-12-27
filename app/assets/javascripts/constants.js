const emailPattern = '^[-a-z0-9_+]+(\.?[-a-z0-9_+]+)*@[a-z0-9][-a-z0-9]*(\.?[-a-z0-9]+)*\.[a-z]{2,}$';
const passwordPattern = '.{8,128}';
const namePattern = '[A-z]{1,40}';
const minPasswordLength = 8;
const minNameLength = 1;

$(function() {
  var matchElements = '[data-pattern="email"],[data-pattern="password"],[data-pattern="name"]'
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
  });
});
  
