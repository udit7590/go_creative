class AddCacheColumnsToProject < ActiveRecord::Migration
  def change
    add_column :projects, :collected_amount, :integer, default: 0
    add_column :projects, :contributors_count, :integer, default: 0
  end
end
