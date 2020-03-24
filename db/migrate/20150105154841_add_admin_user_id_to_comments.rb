class AddAdminUserIdToComments < ActiveRecord::Migration
  def change
    add_column :comments, :admin_user_id, :integer
  end
end
