module AccountHelper
  def address_string(index)
    index == 0 ? 'Current Address' : 'Permanent Address'
  end
end
