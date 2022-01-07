class AddFloorAndPotentialRoyalties < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :floor_royalties, :decimal, default: 0
    add_column :tokens, :potential_royalties, :decimal, default: 0
  end
end
