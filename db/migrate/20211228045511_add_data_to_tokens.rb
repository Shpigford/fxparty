class AddDataToTokens < ActiveRecord::Migration[7.0]
  def change
    add_column :tokens, :supply, :integer
    add_column :tokens, :balance, :integer
    add_column :tokens, :royalties, :decimal
    add_column :tokens, :author_name, :string
    add_column :tokens, :author_address, :string
    add_column :tokens, :author_avatar, :string
  end
end
