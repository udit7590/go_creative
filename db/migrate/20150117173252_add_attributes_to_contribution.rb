class AddAttributesToContribution < ActiveRecord::Migration
  def change
    add_column :contributions, :card_type, :string
    add_column :contributions, :card_expires_on, :date
    # Postgres specific
    add_column :contributions, :ip_address, :inet
    add_column :contributions, :network_address, :cidr
  end
end
