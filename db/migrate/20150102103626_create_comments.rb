class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.integer :parent_id
      t.references :user
      t.references :project
      t.text :description
      t.boolean :spam, default: false
      t.boolean :visible_to_all, default: true

      t.timestamps
    end
  end
end
