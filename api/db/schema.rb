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

ActiveRecord::Schema[8.0].define(version: 2025_12_18_093859) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  # Custom types defined in this database.
  # Note that some types may not work with other database engines. Be careful if changing database.
  create_enum "accounting_financial_transaction_status", ["draft", "voided", "posted", "cancelled"]
  create_enum "credit_note_status", ["draft", "published"]
  create_enum "invoice_status", ["draft", "published", "cancelled"]
  create_enum "legal_form", ["sasu", "sas", "eurl", "sa", "auto_entrepreneur"]

  create_table "accounting_financial_transaction_details", force: :cascade do |t|
    t.bigint "financial_transaction_id", null: false
    t.datetime "delivery_date", null: false
    t.string "seller_name", null: false
    t.string "seller_registration_number", null: false
    t.string "seller_address_zipcode", null: false
    t.string "seller_address_street", null: false
    t.string "seller_address_city", null: false
    t.string "seller_vat_number", null: false
    t.string "client_name", null: false
    t.string "client_registration_number"
    t.string "client_address_zipcode", null: false
    t.string "client_address_street", null: false
    t.string "client_address_city", null: false
    t.string "client_vat_number"
    t.string "delivery_name", null: false
    t.string "delivery_registration_number"
    t.string "delivery_address_zipcode", null: false
    t.string "delivery_address_street", null: false
    t.string "delivery_address_city", null: false
    t.string "purchase_order_number"
    t.datetime "due_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "seller_phone", null: false
    t.string "seller_email", null: false
    t.string "client_phone", null: false
    t.string "client_email", null: false
    t.string "delivery_phone", null: false
    t.string "delivery_email", null: false
    t.enum "seller_legal_form", null: false, enum_type: "legal_form"
    t.decimal "seller_capital_amount", precision: 10, scale: 2, null: false
    t.string "seller_rcs_city", null: false
    t.string "seller_rcs_number", null: false
    t.integer "payment_term_days", null: false
    t.string "payment_term_accepted_methods", default: [], null: false, array: true
    t.text "general_terms_and_conditions"
    t.string "bank_detail_iban", null: false
    t.string "bank_detail_bic", null: false
    t.index ["financial_transaction_id"], name: "idx_on_financial_transaction_id_a3f0028db5"
  end

  create_table "accounting_financial_transaction_lines", force: :cascade do |t|
    t.string "holder_id", null: false
    t.bigint "financial_transaction_id", null: false
    t.string "unit", null: false
    t.decimal "unit_price_amount", precision: 15, scale: 2, null: false
    t.decimal "quantity", precision: 15, scale: 6, null: false
    t.decimal "tax_rate", precision: 15, scale: 2, null: false
    t.decimal "excl_tax_amount", precision: 15, scale: 2, null: false
    t.bigint "group_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["financial_transaction_id"], name: "idx_on_financial_transaction_id_7c8e3e3158"
    t.index ["group_id"], name: "index_accounting_financial_transaction_lines_on_group_id"
    t.index ["holder_id"], name: "index_accounting_financial_transaction_lines_on_holder_id"
  end

  create_table "accounting_financial_transactions", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.bigint "holder_id"
    t.enum "status", default: "draft", null: false, enum_type: "accounting_financial_transaction_status"
    t.string "number"
    t.string "type", null: false
    t.datetime "issue_date", null: false
    t.jsonb "context", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "total_excl_tax_amount", precision: 15, scale: 2, null: false
    t.decimal "total_including_tax_amount", precision: 15, scale: 2, null: false
    t.decimal "total_excl_retention_guarantee_amount", precision: 15, scale: 2, null: false
    t.bigint "client_id", null: false
    t.bigint "financial_year_id"
    t.index ["client_id"], name: "index_accounting_financial_transactions_on_client_id"
    t.index ["company_id"], name: "index_accounting_financial_transactions_on_company_id"
    t.index ["context"], name: "index_accounting_financial_transactions_on_context", using: :gin
    t.index ["financial_year_id"], name: "index_accounting_financial_transactions_on_financial_year_id"
    t.index ["holder_id"], name: "index_accounting_financial_transactions_on_holder_id"
  end

  create_table "accounting_financial_years", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.datetime "start_date"
    t.datetime "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id"], name: "index_accounting_financial_years_on_company_id"
  end

  create_table "accounting_payments", force: :cascade do |t|
    t.bigint "invoice_id", null: false
    t.decimal "amount", null: false
    t.datetime "received_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_accounting_payments_on_invoice_id"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

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

  create_table "organization_bank_details", force: :cascade do |t|
    t.string "name", null: false
    t.string "iban", null: false
    t.string "bic", null: false
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["company_id", "iban"], name: "index_organization_bank_details_on_company_id_and_iban", unique: true
    t.index ["company_id"], name: "index_organization_bank_details_on_company_id"
  end

  create_table "organization_clients", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.string "name", null: false
    t.string "registration_number"
    t.string "email", null: false
    t.string "phone", null: false
    t.string "address_street", null: false
    t.string "address_city", null: false
    t.string "address_zipcode", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "vat_number"
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
    t.decimal "capital_amount", precision: 15, scale: 2, null: false
    t.index ["registration_number"], name: "index_organization_companies_on_registration_number", unique: true
  end

  create_table "organization_company_configs", force: :cascade do |t|
    t.bigint "company_id", null: false
    t.jsonb "settings", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "default_vat_rate", precision: 10, scale: 2, null: false
    t.integer "payment_term_days", null: false
    t.string "payment_term_accepted_methods", default: [], null: false, array: true
    t.text "general_terms_and_conditions", null: false
    t.integer "financial_year_start_month", default: 1, null: false
    t.index ["company_id"], name: "index_organization_company_configs_on_company_id"
    t.index ["settings"], name: "index_organization_company_configs_on_settings", using: :gin
  end

  create_table "organization_item_groups", force: :cascade do |t|
    t.bigint "project_version_id", null: false
    t.string "name", null: false
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
    t.decimal "quantity", precision: 10, scale: 2, null: false
    t.string "unit", null: false
    t.decimal "unit_price_amount", precision: 15, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "project_version_id", null: false
    t.bigint "item_group_id"
    t.integer "position", null: false
    t.uuid "original_item_uuid", null: false
    t.decimal "tax_rate", precision: 5, scale: 2, null: false
    t.index ["item_group_id"], name: "index_organization_items_on_item_group_id"
    t.index ["original_item_uuid"], name: "index_organization_items_on_original_item_uuid"
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
    t.decimal "retention_guarantee_rate", precision: 3, scale: 2
    t.decimal "total_excl_tax_amount", precision: 15, scale: 2, null: false
    t.string "general_terms_and_conditions"
    t.index ["project_id"], name: "index_organization_project_versions_on_project_id"
  end

  create_table "organization_projects", force: :cascade do |t|
    t.bigint "client_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "description"
    t.string "type", null: false
    t.bigint "original_project_version_id"
    t.bigint "company_id", null: false
    t.integer "number", null: false
    t.boolean "posted", default: false, null: false
    t.datetime "posted_at"
    t.string "address_street", null: false
    t.string "address_zipcode", null: false
    t.string "address_city", null: false
    t.bigint "bank_detail_id"
    t.string "po_number"
    t.index ["bank_detail_id"], name: "index_organization_projects_on_bank_detail_id"
    t.index ["client_id"], name: "index_organization_projects_on_client_id"
    t.index ["company_id", "type", "number"], name: "index_organization_projects_on_company_id_and_type_and_number", unique: true
    t.index ["company_id"], name: "index_organization_projects_on_company_id"
    t.index ["name", "client_id", "type"], name: "index_organization_projects_on_name_and_client_id_and_type", unique: true
    t.index ["original_project_version_id"], name: "index_organization_projects_on_original_project_version_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.datetime "last_login_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "accounting_financial_transaction_details", "accounting_financial_transactions", column: "financial_transaction_id"
  add_foreign_key "accounting_financial_transaction_lines", "accounting_financial_transactions", column: "financial_transaction_id"
  add_foreign_key "accounting_financial_transactions", "accounting_financial_years", column: "financial_year_id"
  add_foreign_key "accounting_payments", "accounting_financial_transactions", column: "invoice_id"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "organization_bank_details", "organization_companies", column: "company_id"
  add_foreign_key "organization_clients", "organization_companies", column: "company_id"
  add_foreign_key "organization_company_configs", "organization_companies", column: "company_id"
  add_foreign_key "organization_item_groups", "organization_project_versions", column: "project_version_id"
  add_foreign_key "organization_items", "organization_item_groups", column: "item_group_id"
  add_foreign_key "organization_items", "organization_project_versions", column: "project_version_id"
  add_foreign_key "organization_members", "organization_companies", column: "company_id"
  add_foreign_key "organization_members", "users"
  add_foreign_key "organization_project_versions", "organization_projects", column: "project_id"
  add_foreign_key "organization_projects", "organization_bank_details", column: "bank_detail_id"
  add_foreign_key "organization_projects", "organization_clients", column: "client_id"
  add_foreign_key "organization_projects", "organization_companies", column: "company_id"
  add_foreign_key "organization_projects", "organization_project_versions", column: "original_project_version_id"

  create_view "monthly_revenues", sql_definition: <<-SQL
      SELECT invoices.company_id,
      (date_part('year'::text, invoices.issue_date))::integer AS year,
      (date_part('month'::text, invoices.issue_date))::integer AS month,
      sum((invoices.total_excl_tax_amount - COALESCE(credit_notes.total_excl_tax_amount, (0)::numeric))) AS total_revenue
     FROM (accounting_financial_transactions invoices
       LEFT JOIN accounting_financial_transactions credit_notes ON (((credit_notes.holder_id = invoices.id) AND ((credit_notes.type)::text = 'Accounting::CreditNote'::text))))
    WHERE ((invoices.type)::text = 'Accounting::Invoice'::text)
    GROUP BY invoices.company_id, ((date_part('year'::text, invoices.issue_date))::integer), ((date_part('month'::text, invoices.issue_date))::integer);
  SQL
  create_view "order_completion_percentages", sql_definition: <<-SQL
      WITH orders AS (
           SELECT organization_projects.id,
              organization_projects.client_id,
              organization_projects.name,
              organization_projects.created_at,
              organization_projects.updated_at,
              organization_projects.description,
              organization_projects.type,
              organization_projects.original_project_version_id,
              organization_projects.company_id,
              organization_projects.number,
              organization_projects.posted,
              organization_projects.posted_at
             FROM organization_projects
            WHERE ((organization_projects.type)::text = 'Organization::Order'::text)
          ), last_version_numbers AS (
           SELECT organization_project_versions.project_id,
              max(organization_project_versions.number) AS last_version_number
             FROM organization_project_versions
            GROUP BY organization_project_versions.project_id
          ), last_versions AS (
           SELECT organization_project_versions.id,
              organization_project_versions.project_id,
              organization_project_versions.number,
              organization_project_versions.created_at,
              organization_project_versions.updated_at,
              organization_project_versions.retention_guarantee_rate,
              organization_project_versions.total_excl_tax_amount
             FROM (organization_project_versions
               JOIN last_version_numbers ON (((organization_project_versions.number = last_version_numbers.last_version_number) AND (organization_project_versions.project_id = last_version_numbers.project_id))))
          ), invoices AS (
           SELECT accounting_financial_transactions.id,
              accounting_financial_transactions.company_id,
              accounting_financial_transactions.holder_id,
              accounting_financial_transactions.status,
              accounting_financial_transactions.number,
              accounting_financial_transactions.type,
              accounting_financial_transactions.issue_date,
              accounting_financial_transactions.context,
              accounting_financial_transactions.created_at,
              accounting_financial_transactions.updated_at,
              accounting_financial_transactions.total_excl_tax_amount,
              accounting_financial_transactions.total_including_tax_amount,
              accounting_financial_transactions.total_excl_retention_guarantee_amount,
              accounting_financial_transactions.client_id
             FROM accounting_financial_transactions
            WHERE ((accounting_financial_transactions.type)::text = 'Accounting::Invoice'::text)
          ), credit_notes AS (
           SELECT accounting_financial_transactions.id,
              accounting_financial_transactions.company_id,
              accounting_financial_transactions.holder_id,
              accounting_financial_transactions.status,
              accounting_financial_transactions.number,
              accounting_financial_transactions.type,
              accounting_financial_transactions.issue_date,
              accounting_financial_transactions.context,
              accounting_financial_transactions.created_at,
              accounting_financial_transactions.updated_at,
              accounting_financial_transactions.total_excl_tax_amount,
              accounting_financial_transactions.total_including_tax_amount,
              accounting_financial_transactions.total_excl_retention_guarantee_amount,
              accounting_financial_transactions.client_id
             FROM accounting_financial_transactions
            WHERE ((accounting_financial_transactions.type)::text = 'Accounting::CreditNote'::text)
          ), amount_invoiced_per_orders AS (
           SELECT organization_project_versions.project_id,
              (COALESCE(sum(invoices.total_excl_tax_amount), 0.00) - COALESCE(sum(credit_notes.total_excl_tax_amount), 0.00)) AS total_excl_tax_amount
             FROM ((organization_project_versions
               LEFT JOIN invoices ON ((organization_project_versions.id = invoices.holder_id)))
               LEFT JOIN credit_notes ON ((invoices.id = credit_notes.holder_id)))
            GROUP BY organization_project_versions.project_id
          )
   SELECT orders.id AS order_id,
      last_versions.total_excl_tax_amount AS order_total_amount,
      amount_invoiced_per_orders.total_excl_tax_amount AS invoiced_total_amount,
      round((amount_invoiced_per_orders.total_excl_tax_amount / last_versions.total_excl_tax_amount), 2) AS completion_percentage
     FROM ((orders
       LEFT JOIN last_versions ON ((orders.id = last_versions.project_id)))
       LEFT JOIN amount_invoiced_per_orders ON ((orders.id = amount_invoiced_per_orders.project_id)));
  SQL
  create_view "invoice_payment_statuses", sql_definition: <<-SQL
      WITH invoices AS (
           SELECT accounting_financial_transactions.id,
              accounting_financial_transactions.company_id,
              accounting_financial_transactions.holder_id,
              accounting_financial_transactions.status,
              accounting_financial_transactions.number,
              accounting_financial_transactions.type,
              accounting_financial_transactions.issue_date,
              accounting_financial_transactions.context,
              accounting_financial_transactions.created_at,
              accounting_financial_transactions.updated_at,
              accounting_financial_transactions.total_excl_tax_amount,
              accounting_financial_transactions.total_including_tax_amount,
              accounting_financial_transactions.total_excl_retention_guarantee_amount,
              accounting_financial_transactions.client_id
             FROM accounting_financial_transactions
            WHERE ((accounting_financial_transactions.type)::text = 'Accounting::Invoice'::text)
          ), invoice_payments AS (
           SELECT invoices.id AS invoice_id,
              sum(COALESCE(accounting_payments.amount, (0)::numeric)) AS invoice_payment
             FROM (invoices
               LEFT JOIN accounting_payments ON ((accounting_payments.invoice_id = invoices.id)))
            GROUP BY invoices.id
          ), invoice_balances AS (
           SELECT invoices.id AS invoice_id,
              (invoices.total_excl_retention_guarantee_amount - invoice_payments.invoice_payment) AS balance
             FROM (invoices
               LEFT JOIN invoice_payments ON ((invoice_payments.invoice_id = invoices.id)))
          )
   SELECT invoice_balances.invoice_id,
          CASE
              WHEN (invoice_balances.balance = (0)::numeric) THEN 'paid'::text
              WHEN (accounting_financial_transaction_details.due_date < COALESCE(((NULLIF(current_setting('app.now'::text, true), ''::text))::timestamp without time zone)::timestamp with time zone, now())) THEN 'overdue'::text
              ELSE 'pending'::text
          END AS status
     FROM (invoice_balances
       LEFT JOIN accounting_financial_transaction_details ON ((accounting_financial_transaction_details.financial_transaction_id = invoice_balances.invoice_id)));
  SQL
end
