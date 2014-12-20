module AccountHelper
  def address_string(is_primary)
    is_primary ? 'Permanent Address' : 'Current Address'
  end
end
