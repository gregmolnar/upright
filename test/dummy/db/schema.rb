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

ActiveRecord::Schema[8.1].define(version: 2025_01_14_000001) do
  create_table "upright_probe_results", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.decimal "duration"
    t.string "probe_name"
    t.string "probe_service"
    t.string "probe_target"
    t.string "probe_type"
    t.integer "status"
    t.datetime "updated_at", null: false
    t.index [ "created_at" ], name: "index_upright_probe_results_on_created_at"
    t.index [ "probe_name" ], name: "index_upright_probe_results_on_probe_name"
    t.index [ "probe_type" ], name: "index_upright_probe_results_on_probe_type"
    t.index [ "status" ], name: "index_upright_probe_results_on_status"
  end
end
