class AddReferenceFields < ActiveRecord::Migration[7.0]
  def change
    add_reference :items, :token, index: true
    add_reference :items, :wallet, index: true
  end
end
