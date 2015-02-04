class ContributionTransaction < ActiveRecord::Base

  belongs_to :contribution

  serialize :params

  def response=(response)
    self.success = response.captured
    self.authorization = response.id
    self.message = response.failure_message
    self.params = response
  rescue ActiveMerchant::ActiveMerchantError => e
    self.success = false
    self.authorization = nil
    self.message = e.message
    self.params = {}
  end

end
