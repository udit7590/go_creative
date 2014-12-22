class AddAttributesToUsers < ActiveRecord::Migration
  def change

    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone_number, :string
    add_attachment :users, :profile_picture
    add_column :users, :pan_card, :string
    add_attachment :users, :pan_card_copy
  end
end
