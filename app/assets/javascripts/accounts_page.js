var AccountsPage = (function() {

  function AccountsPage(panCardUploadBoxName, addressProofUploadBoxName, currentAddressProofUploadBoxName, current_address_checkbox, permanent_address_container, current_address_container, pancard_warn_text, primary_address_warn_text, current_address_warn_text) {

    this.panCardUploadBoxName = "#" + panCardUploadBoxName;
    this.addressProofUploadBoxName= "#" + addressProofUploadBoxName;
    this.currentAddressProofUploadBoxName= "#" + currentAddressProofUploadBoxName;

    this.pancardDropzone = null;
    this.addressProofDropzone = null;
    this.currentAddressProofDropzone = null;

    this.$current_address_checkbox = current_address_checkbox;
    this.$permanent_address_container = permanent_address_container;
    this.$current_address_container = current_address_container;
    this.$pancard_warn_text = pancard_warn_text;
    this.$primary_address_warn_text = primary_address_warn_text;
    this.$current_address_warn_text = current_address_warn_text;

  }

  AccountsPage.prototype.createDropZonesForUpload = function() {
    try {
      this.pancardDropzone = new Dropzone(this.panCardUploadBoxName, {
        maxFilesize: 2, // MB
        maxFiles: 1,
        addRemoveLinks: true,
        paramName: "user[pan_card_copy]",
      });
    } catch (err) {
      // FIXME_AB: Console.log doesn't work in IE. There are some articles available on internet to make them work. Please follow them.
      console.log(err)
    }

    try {
      this.addressProofDropzone = new Dropzone(this.addressProofUploadBoxName, {
        maxFilesize: 2, // MB
        maxFiles: 1,
        addRemoveLinks: true,
        paramName: "address[address_proof]",
      });

      this.currentAddressProofDropzone = new Dropzone(this.currentAddressProofUploadBoxName, {
        maxFilesize: 2, // MB
        maxFiles: 1,
        addRemoveLinks: true,
        paramName: "address[address_proof]",
      });
    } catch (err) {
      console.log(err)
    }

  };

  AccountsPage.prototype.bindEventsForDropzones = function() {
    var _this = this;

    if(this.pancardDropzone) {
      this.pancardDropzone.on('success', function(file, response) {
        alert('Your pancard copy is successfully uploaded.');
        replaceImageAfterUpload(_this.$pancard_warn_text, response.filename, this);
      });
    }

    if(this.addressProofDropzone) {
      this.addressProofDropzone.on('success', function(file, response) {
        alert('Your address proof copy is successfully uploaded.');
        replaceImageAfterUpload(_this.$primary_address_warn_text, response.filename, this);
      });
    }

    if(this.currentAddressProofDropzone) {
      this.currentAddressProofDropzone.on('success', function(file, response) {
        alert('Your current address proof copy is successfully uploaded.');
        replaceImageAfterUpload(_this.$current_address_warn_text, response.filename, this);
      });
    }
  };

  AccountsPage.prototype.bindEventsForCurrentAddressCheckbox = function() {
    var _this = this;

    this.$current_address_checkbox.change(function() {

      if(this.checked) {
        
        parentElements = _this.$permanent_address_container.find('[data-class="primary-address-field"]');
        childElements = _this.$current_address_container.find('[data-class="current-address-field"]');

        parentElements.each(function() {
          childElements.filter('[data-field=' + $(this).data('field') + ']').val(this.value);
        });

        //Hide current address form fields and disable the dropzone
        _this.$current_address_container.find('div.control-group:not(:first)').hide();
        if(_this.currentAddressProofDropzone) {
          _this.currentAddressProofDropzone.disable();
        }
        
      } else {
        //Show current address form fields and Enable the dropzone
        _this.$current_address_container.find('div.control-group:not(:first)').show();
        if(_this.currentAddressProofDropzone) {
          _this.currentAddressProofDropzone.enable();
        }
      }
    });
  };

  AccountsPage.prototype.bindEvents = function() {
    this.bindEventsForDropzones();
    this.bindEventsForCurrentAddressCheckbox();

  };

  //-----------------------------------
  //Section for private Functions
  //-----------------------------------

  function replaceImageAfterUpload(container, imagePath, dropzone) {
    var $imageLink = container.find('a');

    if($imageLink.length ) {
      $imageLink.attr('href', imagePath);
      $imageLink.children('img').attr('src', imagePath).attr('width', '100px').attr('height', '100px');
    } else {
      $imageLink = $('<a>', { href: imagePath })
                  .data('lightbox', imagePath)
                  .html($('<img>', { src: imagePath }));

      container.removeClass('text-warning').text('Your image uploaded successfully.')
         .prepend($imageLink);
    }

    dropzone.removeAllFiles();

  }

  //Return the class
  return AccountsPage;
})();
