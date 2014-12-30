class AddStateToMigration < ActiveRecord::Migration
  def change
    add_column :projects, :state, :string, default: 'created'
    add_index :projects, :state
  end
end
