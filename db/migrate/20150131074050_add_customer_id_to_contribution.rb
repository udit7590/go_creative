class AddCustomerIdToContribution < ActiveRecord::Migration[5.1]
  def change
    add_column :contributions, :stripe_customer_id, :string
  end
end
