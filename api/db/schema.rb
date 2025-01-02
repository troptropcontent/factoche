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

ActiveRecord::Schema[8.0].define(version: 2024_12_31_092818) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "organization_clients", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name", null: false
    t.string "registration_number", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.string "address_street", null: false
    t.string "address_city", null: false
    t.string "address_zipcode", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_organization_clients_on_company_id"
    t.index ["registration_number", "company_id"], name: "idx_on_registration_number_company_id_fc061ed019", unique: true
  end

  create_table "organization_companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "registration_number", null: false
    t.string "email", null: false
    t.string "phone", null: false
    t.string "address_city", null: false
    t.string "address_street", null: false
    t.string "address_zipcode", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["registration_number"], name: "index_organization_companies_on_registration_number", unique: true
  end

  create_table "organization_item_groups", force: :cascade do |t|
    t.bigint "project_version_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "project_version_id"], name: "index_organization_item_groups_on_name_and_project_version_id", unique: true
    t.index ["project_version_id"], name: "index_organization_item_groups_on_project_version_id"
  end

  create_table "organization_members", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_organization_members_on_company_id"
    t.index ["user_id", "company_id"], name: "index_organization_members_on_user_id_and_company_id", unique: true
    t.index ["user_id"], name: "index_organization_members_on_user_id"
  end

  create_table "organization_project_versions", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.integer "number", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_organization_project_versions_on_project_id"
  end

  create_table "organization_projects", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.integer "retention_guarantee_rate", default: 0, null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["client_id"], name: "index_organization_projects_on_client_id"
    t.index ["name", "client_id"], name: "index_organization_projects_on_name_and_client_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "organization_clients", "organization_companies", column: "company_id"
  add_foreign_key "organization_item_groups", "organization_project_versions", column: "project_version_id"
  add_foreign_key "organization_members", "organization_companies", column: "company_id"
  add_foreign_key "organization_members", "users"
  add_foreign_key "organization_project_versions", "organization_projects", column: "project_id"
  add_foreign_key "organization_projects", "organization_clients", column: "client_id"
end
