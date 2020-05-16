class CreateAbuses < ActiveRecord::Migration[5.1]
  def change
    create_table :abuses do |t|
      t.integer :user_id

      # For polymorphic association (Creates 2 columns: abusable_id, and abusable_type)
      t.references :abusable, polymorphic: true

      t.timestamps
    end
  end
end
