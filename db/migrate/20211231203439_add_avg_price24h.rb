class AddAvgPrice24h < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :avg_price_24h, :decimal
  end
end
