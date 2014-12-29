// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

function switchModalWindow(firstModal, secondModal){
  $('#' + firstModal).modal('hide');
  $('#' + secondModal).modal('show');
}
$(function() {
  $('.modal').on('hidden.bs.modal', function (e) {
    $(this).find('form').trigger('reset');
    $(this).find('.alert.alert-error').remove();
  });

  $('#userRegistrationModal,#userLoginModal').on('submit', function() {
    $(this).find('input[type=submit]').attr("disabled", true);
    $modalBox.find('input[type=submit]').attr('value', "Please wait...");
  });
});