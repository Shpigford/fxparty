class AddStatsToWallets < ActiveRecord::Migration[7.0]
  def change
    add_column :wallets, :stat_cost_basis, :decimal
    add_column :wallets, :stat_floor_value, :decimal
    add_column :wallets, :stat_unrealized_gains, :decimal
    add_column :wallets, :stat_size, :integer
  end
end
