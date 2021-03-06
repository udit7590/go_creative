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

  #FIXME_AB: Too much html in helper
  def address_upload_text_image(address)

    primary_address_class = 'primary-address-upload'
    current_address_class = 'current-address-upload'

    if address
      image_available = %{
      <p class="#{ address.primary? ? primary_address_class : current_address_class }">
      <a href="#{ address.address_proof }" data-lightbox="#{ address.address_proof_file_name
 }" data-title="Your Address Proof"><img src = "#{ address.address_proof }", width="100", height="100" /></a><br />
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

  #FIXME_AB: too much html in helpers. Also User's input is being used in html and finally made html_safe. Could be security issue
  def pancard_upload_text_image(pan_card_copy)
    pan_card_copy_class = 'pancard-copy-upload'
    pan_card_copy_available = %{
      <p class="#{ pan_card_copy_class }">
        <a href="#{ pan_card_copy }" data-lightbox="#{ pan_card_copy.instance.pan_card_copy_file_name
 }" data-title="PAN Card"><img src = "#{ pan_card_copy }", width="100", height="100"/></a><br />
        This is the copy available with us. You can provide the proof again using the dropbox below.<p>
    }

    pan_card_copy_not_available = %{
      <p class="text-warning #{ pan_card_copy_class }">
      You have not attached any proof for your pan card till now. Please provide us the proof if you want to start a project on our website. The details will be kept confidential with us.</p>
    }

    (pan_card_copy.exists? ? pan_card_copy_available : pan_card_copy_not_available).html_safe
  end

  def pan_status(user)
    if(user && user.pan_details_verified?)
      '<span class="success">Verified</span>'.html_safe
    else
      '<span class="warning">Not Verified</span>'.html_safe
    end
  end

  def address_status(address)
    if(address.try(:verified_at))
      '<span class="success">Verified</span>'.html_safe
    else
      '<span class="warning">Not Verified</span>'.html_safe
    end
  end

  def image_path(image)
    image.exists? ? image.url : nil
  end

end
