class ChangeCardTypeColumnInContribution < ActiveRecord::Migration[5.1]
  def change
    rename_column :contributions, :card_type, :brand
  end
end
