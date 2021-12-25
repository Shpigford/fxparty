class CreateItems < ActiveRecord::Migration[7.0]
  def change
    create_table :items do |t|
      t.integer :fxid
      t.integer :token_fxid
      t.string :wallet
      t.string :name
      t.string :transaction_hash
      t.decimal :last_purchase_price_tz
      t.string :image_url
      t.timestamps
    end
  end
end
