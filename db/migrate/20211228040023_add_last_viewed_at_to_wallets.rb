class AddLastViewedAtToWallets < ActiveRecord::Migration[7.0]
  def change
    add_column :wallets, :last_viewed_at, :datetime
  end
end
