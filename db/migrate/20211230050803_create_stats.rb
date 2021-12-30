class CreateStats < ActiveRecord::Migration[7.0]
  def change
    create_table :stats do |t|
      t.references :token, null: false, foreign_key: true
      t.string :metric
      t.decimal :value
      t.datetime :captured_at
    end
  end
end
