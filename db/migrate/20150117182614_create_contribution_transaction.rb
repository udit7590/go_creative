class CreateContributionTransaction < ActiveRecord::Migration
  def change
    create_table :contribution_transactions do |t|
      t.belongs_to :contribution
      t.string :action
      t.integer :amount
      t.boolean :success
      t.string :authorization
      t.string :message
      t.text :params
      t.timestamps
    end
  end
end
