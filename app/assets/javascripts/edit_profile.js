$(function() {
  //To fix dropzone already initialized error
  Dropzone.autoDiscover = false;

  var $dropboxes = $('.dropbox'),
      $current_address_checkbox = $('#current_address_checkbox'),
      $permanent_address_container = $('.primary-address'),
      $current_address_container = $('.current-address'),
      accountsPage = new AccountsPage('pancard_upload', 
                                        'primary_address_proof_upload', 
                                        'current_address_proof_upload', 
                                        $current_address_checkbox, 
                                        $permanent_address_container, 
                                        $current_address_container, 
                                        $('#user_pan_card').find('p.pancard-copy-upload'),
                                        $('#user_address').find('p.primary-address-upload'),
                                        $('#user_address').find('p.current-address-upload')
                                      );
  try {
    accountsPage.createDropZonesForUpload();
    accountsPage.bindEvents();
  } catch(err) {
    console.log(err)
  }

  //Select Tab based on url hash
  $('ul.nav a').click(function() {
    window.location.hash = $(this).attr('href');
  });
  if(window.location.hash) {
    $('ul.nav a[href="' + window.location.hash + '"]').tab('show');
  }
  
});
