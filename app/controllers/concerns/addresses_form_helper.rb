module AddressesFormHelper

  # Also builds one of the address as primary
  def build_max_n_addresses(user, number)
    return [] if number < 1

    existing = user.addresses.count

    unless  primary_address = user.addresses.detect(&:primary?)
      primary_address = user.addresses.build(primary: true)
      existing += 1
    end

    (number - existing).times { user.addresses.build }

    #Fixes out of order addresses by sorting the collection proxy object. 
    #Collection proxy stores the associated objects in @association.target
    addresses = user.addresses.instance_variable_get(:@association).target
    index = addresses.index(primary_address)
    addresses[0], addresses[1] = addresses[1], addresses[0] if index.nonzero?
  end

end
