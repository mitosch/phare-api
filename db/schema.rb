# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_02_11_163745) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audit_reports", force: :cascade do |t|
    t.jsonb "body", default: {}, null: false
    t.integer "audit_type", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "page_id", null: false
    t.index ["page_id"], name: "index_audit_reports_on_page_id"
  end

  create_table "pages", force: :cascade do |t|
    t.text "url"
    t.integer "status", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "audit_reports", "pages"
end
