class UserVerification
  
  # Only admin can verify the user details
  def self.verify_details(user, admin, should_verify_current_address = false)
    verified = verify_pan(user, admin)
    verified &&=  verify_address(user.addresses.primary_address, admin)

    if should_verify_current_address
      verified &&= verify_address(user.addresses.current_address, admin)
    end

    verified
  end

  def self.verify_pan(user, admin)
    user.pan_details_verified? ? true : user.update(pan_verified_at: DateTime.current, pan_verified_by: admin.id)
  end

  def self.verify_address(address, admin)
    address ? !!(address.verified_at || address.update(verified_at: DateTime.current, admin_user_id: admin.id)) : false
  end
end
