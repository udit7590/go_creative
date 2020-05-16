class AddAdminUserIdToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :admin_user_id, :integer
  end
end
