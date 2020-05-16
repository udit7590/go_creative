class AddStateToMigration < ActiveRecord::Migration[5.1]
  def change
    add_column :projects, :state, :string, default: 'created'
    add_index :projects, :state
  end
end
