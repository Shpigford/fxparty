class AddDelistedToTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :delisted, :boolean, default: false
  end
end
