$(document).ready(function() {
  //Load the checkout script from stripe server
  $.getScript("https://checkout.stripe.com/checkout.js", function(){
    console.log("Sprite checkout script loaded.");
    var $paymentButton = $('#contribution-confirm');
      
    $paymentButton.removeAttr('disabled');

    // Configure the stripe checkout form and define what happens on response
    var handler = StripeCheckout.configure({
      key: 'pk_test_SHyWyP14xAqLDiJnxR0Q2Kdc',
      token: function(token) {
        console.log(token);
        var $form = $('#new_contribution');
        //Send the request to add contributor(if not already added) and hold the payment 
        $('#stripe_token').val(token);
        $form.append($('<input type="hidden" name="stripeToken" />').val(token.id));
        $form.append($('<input type="hidden" name="stripeTokenParams" />').val(JSON.stringify(token)));
        $form.submit();
      }
    });

    //Register for payment button click event
    $paymentButton.on('click', function(e) {
      e.preventDefault();
      var $amountField = $('#contribution_amount'),
          contributedAmount = Math.floor($amountField.val()), //amount to be sent in paisa and integer figure
          $this = $(this);
      $this.attr('disabled', true);
      if(contributedAmount >= $this.data('min-amount') && contributedAmount <= $this.data('max-amount')) {
        // Open Checkout with further options
        handler.open({
          name: 'Go Creative',
          description: 'Project Contribution',
          amount: contributedAmount * 100, //In Paisa
          currency: 'INR',
          email: $this.data('user-email')
        });

        // Close Checkout on page navigation
        $(window).on('popstate', function() {
          handler.close();
        });
      } else {
        alert('Please enter a valid amount.');
        $amountField.focus();
      }
      $this.removeAttr('disabled');
    });
  });

});
