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

ActiveRecord::Schema[7.2].define(version: 2025_02_10_000006) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "import_sessions", force: :cascade do |t|
    t.string "status", default: "draft", null: false
    t.string "file_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "properties", force: :cascade do |t|
    t.string "building_name", null: false
    t.string "street_address", null: false
    t.string "city", null: false
    t.string "state", null: false
    t.string "zip_code", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["building_name", "street_address", "city", "state", "zip_code"], name: "index_properties_on_composite_identity", unique: true
  end

  create_table "staged_rows", force: :cascade do |t|
    t.bigint "import_session_id", null: false
    t.integer "row_number", null: false
    t.string "building_name", null: false
    t.string "street_address", null: false
    t.string "unit_number"
    t.string "city", null: false
    t.string "state", null: false
    t.string "zip_code", null: false
    t.text "validation_errors"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "skip_unit", default: false, null: false
    t.boolean "skip_property", default: false, null: false
    t.index ["import_session_id"], name: "index_staged_rows_on_import_session_id"
  end

  create_table "units", force: :cascade do |t|
    t.bigint "property_id", null: false
    t.string "unit_number", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["property_id", "unit_number"], name: "index_units_on_property_id_and_unit_number", unique: true
    t.index ["property_id"], name: "index_units_on_property_id"
  end

  add_foreign_key "staged_rows", "import_sessions"
  add_foreign_key "units", "properties"
end
