class AddMintPercentageToTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :mint_progress, :decimal
  end
end
