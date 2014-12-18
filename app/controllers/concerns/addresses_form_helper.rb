module AddressesFormHelper
  extend ActiveSupport::Concern

  def build_max_n_addresses(user, number) 
    address_count = user.addresses.count 
    (number - address_count).times { user.addresses.build }
  end

end
