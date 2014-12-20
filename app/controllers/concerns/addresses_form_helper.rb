module AddressesFormHelper

  # Also builds one of the address as primary
  def build_max_n_addresses(user, number) 
    address_count = user.addresses.count
    case address_count
    when 1
      user.addresses.build
      user.addresses[1].primary = (user.addresses[0].primary? ? true : false)
      (number - address_count - 2).times { user.addresses.build }
    else
      (number - address_count).times { user.addresses.build }
      user.addresses[0].primary = true
    end
  end

end
