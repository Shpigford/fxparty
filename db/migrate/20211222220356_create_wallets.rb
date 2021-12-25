class CreateWallets < ActiveRecord::Migration[7.0]
  def change
    create_table :wallets do |t|
      t.string :address
      t.datetime :last_updated_at

      t.timestamps
    end
  end
end
