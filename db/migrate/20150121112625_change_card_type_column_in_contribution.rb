class ChangeCardTypeColumnInContribution < ActiveRecord::Migration
  def change
    rename_column :contributions, :card_type, :brand
  end
end
