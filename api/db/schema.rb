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

ActiveRecord::Schema[8.0].define(version: 2025_02_10_150605) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "legal_form", ["sasu", "sas", "eurl", "sa", "auto_entrepreneur"]

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "organization_accounting_documents", force: :cascade do |t|
    t.string "type", null: false
    t.integer "total_amount_cents", null: false
    t.datetime "date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "number", null: false
    t.datetime "issue_date", null: false
    t.datetime "delivery_date", null: false
    t.decimal "total_amount_excl_tax", precision: 15, scale: 2, null: false
    t.decimal "total_amount_incl_tax", precision: 15, scale: 2, null: false
    t.decimal "tax_amount", precision: 15, scale: 2, null: false
    t.decimal "retention_guarantee_amount", precision: 15, scale: 2, default: "0.0", null: false
    t.jsonb "data", default: {}, null: false
    t.index ["data"], name: "index_organization_accounting_documents_on_data", using: :gin
  end

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
    t.enum "legal_form", default: "sas", null: false, enum_type: "legal_form"
    t.string "rcs_city", null: false
    t.string "rcs_number", null: false
    t.string "vat_number", null: false
    t.integer "capital_amount_cents", null: false
    t.index ["registration_number"], name: "index_organization_companies_on_registration_number", unique: true
  end

  create_table "organization_company_configs", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_organization_company_configs_on_company_id"
    t.index ["settings"], name: "index_organization_company_configs_on_settings", using: :gin
  end

  create_table "organization_completion_snapshot_items", force: :cascade do |t|
    t.bigint "item_id", null: false
    t.bigint "completion_snapshot_id", null: false
    t.decimal "completion_percentage", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["completion_snapshot_id"], name: "idx_on_completion_snapshot_id_f747b636af"
    t.index ["item_id"], name: "index_organization_completion_snapshot_items_on_item_id"
  end

  create_table "organization_completion_snapshots", force: :cascade do |t|
    t.bigint "project_version_id", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "invoice_id"
    t.bigint "credit_note_id"
    t.index ["credit_note_id"], name: "index_organization_completion_snapshots_on_credit_note_id"
    t.index ["invoice_id"], name: "index_organization_completion_snapshots_on_invoice_id"
    t.index ["project_version_id"], name: "index_organization_completion_snapshots_on_project_version_id"
  end

  create_table "organization_item_groups", force: :cascade do |t|
    t.bigint "project_version_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position", null: false
    t.string "description"
    t.index ["name", "project_version_id"], name: "index_organization_item_groups_on_name_and_project_version_id", unique: true
    t.index ["project_version_id"], name: "index_organization_item_groups_on_project_version_id"
  end

  create_table "organization_items", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.integer "quantity", null: false
    t.string "unit", null: false
    t.integer "unit_price_cents", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_version_id", null: false
    t.bigint "item_group_id"
    t.integer "position", null: false
    t.index ["item_group_id"], name: "index_organization_items_on_item_group_id"
    t.index ["project_version_id"], name: "index_organization_items_on_project_version_id"
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
    t.integer "retention_guarantee_rate"
    t.index ["project_id"], name: "index_organization_project_versions_on_project_id"
  end

  create_table "organization_projects", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
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

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "organization_clients", "organization_companies", column: "company_id"
  add_foreign_key "organization_company_configs", "organization_companies", column: "company_id"
  add_foreign_key "organization_completion_snapshot_items", "organization_completion_snapshots", column: "completion_snapshot_id"
  add_foreign_key "organization_completion_snapshot_items", "organization_items", column: "item_id"
  add_foreign_key "organization_completion_snapshots", "organization_accounting_documents", column: "credit_note_id"
  add_foreign_key "organization_completion_snapshots", "organization_accounting_documents", column: "invoice_id"
  add_foreign_key "organization_completion_snapshots", "organization_project_versions", column: "project_version_id"
  add_foreign_key "organization_item_groups", "organization_project_versions", column: "project_version_id"
  add_foreign_key "organization_items", "organization_item_groups", column: "item_group_id"
  add_foreign_key "organization_items", "organization_project_versions", column: "project_version_id"
  add_foreign_key "organization_members", "organization_companies", column: "company_id"
  add_foreign_key "organization_members", "users"
  add_foreign_key "organization_project_versions", "organization_projects", column: "project_id"
  add_foreign_key "organization_projects", "organization_clients", column: "client_id"
end
