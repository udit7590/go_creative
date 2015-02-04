class AddCustomerIdToContribution < ActiveRecord::Migration
  def change
    add_column :contributions, :stripe_customer_id, :string
  end
end
