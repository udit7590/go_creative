class AddPanStatusFieldsToUsers < ActiveRecord::Migration[5.1]
  def change
    # When the admin verifies the PAN
    add_column :users, :pan_verified_at, :datetime
    # Which admin verified the PAN
    add_column :users, :pan_verified_by, :integer
  end
end
