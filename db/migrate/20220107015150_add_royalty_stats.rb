class AddRoyaltyStats < ActiveRecord::Migration[7.0]
  def change
    add_column :wallets, :stat_floor_royalties, :decimal, default: 0
    add_column :wallets, :stat_potential_royalties, :decimal, default: 0
  end
end
