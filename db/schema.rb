# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_12_30_050803) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "items", force: :cascade do |t|
    t.integer "fxid"
    t.integer "token_fxid"
    t.string "wallet"
    t.string "name"
    t.string "transaction_hash"
    t.decimal "last_purchase_price_tz"
    t.string "image_url"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "token_id"
    t.bigint "wallet_id"
    t.index ["token_id"], name: "index_items_on_token_id"
    t.index ["wallet_id"], name: "index_items_on_wallet_id"
  end

  create_table "stats", force: :cascade do |t|
    t.bigint "token_id", null: false
    t.string "metric"
    t.decimal "value"
    t.datetime "captured_at", precision: 6
    t.index ["token_id"], name: "index_stats_on_token_id"
  end

  create_table "tokens", force: :cascade do |t|
    t.string "name"
    t.integer "fxid"
    t.decimal "floor"
    t.decimal "median"
    t.decimal "total_listing"
    t.decimal "highest_sold"
    t.decimal "lowest_sold"
    t.decimal "prim_total"
    t.decimal "sec_volume_tz"
    t.decimal "sec_volume_nb"
    t.decimal "sec_volume_tz_24"
    t.decimal "sec_volume_nb_24"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.boolean "delisted", default: false
    t.integer "supply"
    t.integer "balance"
    t.decimal "royalties"
    t.string "author_name"
    t.string "author_address"
    t.string "author_avatar"
    t.decimal "mint_progress"
  end

  create_table "wallets", force: :cascade do |t|
    t.string "address"
    t.datetime "last_updated_at", precision: 6
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "status", default: "syncing"
    t.datetime "last_viewed_at", precision: 6
    t.string "domain"
  end

  add_foreign_key "stats", "tokens"
end
