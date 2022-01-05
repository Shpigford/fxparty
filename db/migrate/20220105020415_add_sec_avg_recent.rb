class AddSecAvgRecent < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :sec_avg_recent, :decimal, default: 0
  end
end
