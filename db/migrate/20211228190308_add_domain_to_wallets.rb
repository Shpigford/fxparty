class AddDomainToWallets < ActiveRecord::Migration[7.0]
  def change
    add_column :wallets, :domain, :string
  end
end
