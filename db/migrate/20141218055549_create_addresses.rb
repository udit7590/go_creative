class CreateAddresses < ActiveRecord::Migration
  def change
    create_table :addresses do |t|
      t.boolean :primary
      t.references :user
      t.string :country
      t.string :state
      t.string :city
      t.integer :pincode
      t.text :full_address

      t.attachment :address_proof

      # When the admin verifies the address
      t.datetime :verified_at
      # Which admin verified the address
      t.integer :admin_user_id
      
      t.timestamps
    end
  end
end
