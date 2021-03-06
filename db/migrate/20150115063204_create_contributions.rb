class CreateContributions < ActiveRecord::Migration[5.1]
  def change
    create_table :contributions do |t|
      t.belongs_to :project, index: true
      t.belongs_to :user, index: true
      t.string :state, default: 'contributed'
      t.timestamps
    end
  end
end
