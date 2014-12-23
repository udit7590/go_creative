class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :title
      t.integer  :amount_required
      t.integer  :min_amount_divisor, default: 10
      t.text :description
      t.datetime :end_date
      t.string :video_link

      # When the admin verifies the project
      t.datetime :verified_at
      # Which admin verified the project
      t.integer :admin_user_id

      # For STI
      t.string :type

      t.references :user

      t.timestamps
    end
  end
end
