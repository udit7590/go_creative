class AddAmountToContributions < ActiveRecord::Migration[5.1]
  def change
    add_column :contributions, :amount, :integer
  end
end
