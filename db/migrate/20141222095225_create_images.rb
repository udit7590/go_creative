class CreateImages < ActiveRecord::Migration[5.1]
  def change
    create_table :images do |t|
      t.attachment :image
      t.boolean :document, default: false

      # For polymorphic association (Creates 2 columns: imageable_id, and imageable_type)
      t.references :imageable, polymorphic: true
      
      t.timestamps
    end
  end
end
