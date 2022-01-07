class AddTrackedToWallet < ActiveRecord::Migration[7.0]
  def change
    add_column :wallets, :tracked, :boolean, default: false
  end
end
