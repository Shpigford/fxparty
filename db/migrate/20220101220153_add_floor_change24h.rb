class AddFloorChange24h < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :floor_change_24h, :decimal, default: 0
  end
end
