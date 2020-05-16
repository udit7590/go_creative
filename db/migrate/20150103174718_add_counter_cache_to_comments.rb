class AddCounterCacheToComments < ActiveRecord::Migration[5.1]
  def change
    add_column :comments, :abused_count, :integer, default: 0
  end
end
