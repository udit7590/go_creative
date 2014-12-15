class AddAttributesToUsers < ActiveRecord::Migration
  def change

    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :country, :string
    add_column :users, :state, :string
    add_column :users, :city, :string
    add_column :users, :pincode, :integer
    add_column :users, :address_line_1, :string
    add_column :users, :address_line_2, :string
    add_column :users, :phone_number, :string

  end
end
