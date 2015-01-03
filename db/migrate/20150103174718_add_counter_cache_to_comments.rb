class AddCounterCacheToComments < ActiveRecord::Migration
  def change
    add_column :comments, :abused_count, :integer, default: 0
  end
end
