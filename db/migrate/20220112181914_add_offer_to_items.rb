class AddOfferToItems < ActiveRecord::Migration[7.0]
  def change
    add_column :items, :offer_price, :decimal, default: nil
  end
end
