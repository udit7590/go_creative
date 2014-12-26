module AccountHelper
  def address_string(is_primary)
    is_primary ? 'Permanent Address' : 'Current Address'
  end

  def address_class(is_primary)
    is_primary ? 'primary-address' : 'current-address'
  end

  def address_field_class(is_primary)
    is_primary ? 'primary-address-field' : 'current-address-field'
  end

  def address_upload_text_image(address)

    primary_address_class = 'primary-address-upload'
    current_address_class = 'current-address-upload'

    if address
      image_available = %{
      <p class="#{ address.primary? ? primary_address_class : current_address_class }">
        <img src = "#{ address.address_proof }" /><br />
        This is the copy available with us. You can provide the proof again using the dropbox below.<p>
      }

      image_not_available = %{
        <p class="text-warning #{ address.primary? ? primary_address_class : current_address_class }">
        You have not attached any proof for your address till now. Please provide us the proof if you want to start a project on our website. The details will be kept confidential with us.</p>
      }

      (address.address_proof.exists? ? image_available : image_not_available).html_safe
    else
      image_not_available = %{
        <p class="text-warning">
        You have not attached any proof for your address till now. Please provide us the proof if you want to start a project on our website. The details will be kept confidential with us.</p>
      }

      image_not_available.html_safe
    end
  end

  def pancard_upload_text_image(pan_card_copy)
    pan_card_copy_class = 'pancard-copy-upload'
    pan_card_copy_available = %{
      <p class="#{ pan_card_copy_class }">
        <img src = "#{ pan_card_copy }" /><br />
        This is the copy available with us. You can provide the proof again using the dropbox below.<p>
    }

    pan_card_copy_not_available = %{
      <p class="text-warning #{ pan_card_copy_class }">
      You have not attached any proof for your pan card till now. Please provide us the proof if you want to start a project on our website. The details will be kept confidential with us.</p>
    }

    (pan_card_copy.exists? ? pan_card_copy_available : pan_card_copy_not_available).html_safe
  end

end
