module AddressesFormHelper

  # Also builds one of the address as primary
  def build_max_n_addresses(user, number) 
    address_count = user.addresses.count
    case address_count
    when 0
      number.times { user.addresses.build }
      user.addresses[0].primary = true
    when 1
      user.addresses.build
      user.addresses[1].primary = (user.addresses[0].primary? ? true : false)
      (number - address_count - 2).times { user.addresses.build }
    else
      no_primary = true
      user.addresses.each { |address| no_primary = false if address.primary? }
      if !no_primary
        (number - address_count).times { user.addresses.build }
      else
        user.addresses.build.primary = true
        (number - address_count - 1).times { user.addresses.build }
      end
    end
  end

end
