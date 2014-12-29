class AddMinAmountProjectPictureToProjects < ActiveRecord::Migration
  def up
    add_column :projects, :min_amount_per_contribution, :decimal, precision: 12, scale: 2
    change_column :projects, :amount_required, :decimal, precision: 12, scale: 2
    add_attachment :projects, :project_picture
  end

  def down
    remove_column :projects, :min_amount_per_contribution
    change_column :projects, :amount_required, :integer
    remove_attachment :projects, :project_picture
  end

end
