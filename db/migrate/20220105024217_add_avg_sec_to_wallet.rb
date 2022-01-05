class AddAvgSecToWallet < ActiveRecord::Migration[7.0]
  def change
    add_column :wallets, :stat_sec_avg_recent, :decimal, default: 0
  end
end
