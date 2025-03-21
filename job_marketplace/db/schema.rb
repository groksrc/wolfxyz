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

ActiveRecord::Schema[8.0].define(version: 2025_03_21_022137) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "clients", force: :cascade do |t|
    t.string "name", null: false
    t.string "company", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_clients_on_email", unique: true
  end

  create_table "job_applications", force: :cascade do |t|
    t.bigint "job_seeker_id", null: false
    t.bigint "opportunity_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["job_seeker_id", "opportunity_id"], name: "idx_job_applications_on_job_seeker_and_opportunity", unique: true
    t.index ["job_seeker_id"], name: "index_job_applications_on_job_seeker_id"
    t.index ["opportunity_id"], name: "index_job_applications_on_opportunity_id"
  end

  create_table "job_seekers", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.text "skills"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_job_seekers_on_email", unique: true
  end

  create_table "opportunities", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.decimal "salary", precision: 10, scale: 2, null: false
    t.bigint "client_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_opportunities_on_client_id"
    t.index ["title"], name: "index_opportunities_on_title"
  end

  add_foreign_key "job_applications", "job_seekers"
  add_foreign_key "job_applications", "opportunities"
  add_foreign_key "opportunities", "clients"
end
