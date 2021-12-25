class CreateTokens < ActiveRecord::Migration[7.0]
  def change
    create_table :tokens do |t|
      t.string :name
      t.integer :fxid
      t.decimal :floor
      t.decimal :median
      t.decimal :total_listing
      t.decimal :highest_sold
      t.decimal :lowest_sold
      t.decimal :prim_total
      t.decimal :sec_volume_tz
      t.decimal :sec_volume_nb
      t.decimal :sec_volume_tz_24
      t.decimal :sec_volume_nb_24

      t.timestamps
    end
  end
end
