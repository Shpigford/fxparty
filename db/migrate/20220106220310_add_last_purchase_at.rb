class AddLastPurchaseAt < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :last_purchase_at, :datetime
  end
end
