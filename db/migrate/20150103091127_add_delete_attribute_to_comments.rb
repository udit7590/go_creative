class AddDeleteAttributeToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :deleted, :boolean, default: false
    add_column :comments, :deleted_at, :datetime
    add_column :comments, :deleted_by, :integer
  end
end
