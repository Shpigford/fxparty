class AddIndexToStats < ActiveRecord::Migration[7.0]
  def change
    add_index :stats, :metric
  end
end
