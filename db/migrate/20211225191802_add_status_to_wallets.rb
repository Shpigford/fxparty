class AddStatusToWallets < ActiveRecord::Migration[7.0]
  def change
    add_column :wallets, :status, :string, default: "syncing"
  end
end
