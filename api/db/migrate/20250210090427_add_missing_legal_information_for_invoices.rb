class AddMissingLegalInformationForInvoices < ActiveRecord::Migration[8.0]
  def change
    create_enum :legal_form, [ "sasu", "sas", "eurl", "sa", "auto_entrepreneur" ]
    add_column :organization_companies, :legal_form, :enum, enum_type: :legal_form, null: false, default: :sas
    add_column :organization_companies, :rcs_city, :string
    add_column :organization_companies, :rcs_number, :string
    add_column :organization_companies, :vat_number, :string
    add_column :organization_companies, :capital_amount_cents, :integer
    add_column :organization_accounting_documents, :number, :string, null: false
    add_column :organization_accounting_documents, :issue_date, :datetime, null: false
    add_column :organization_accounting_documents, :delivery_date, :datetime, null: false
    add_column :organization_accounting_documents, :amount_cents, :integer, null: false
    add_column :organization_accounting_documents, :retention_guarantee_cents, :integer, null: false
    add_column :organization_accounting_documents, :tax_cents, :integer, null: false
    add_column :organization_accounting_documents, :data, :jsonb, null: false, default: {}
    add_index :organization_accounting_documents, :data, using: :gin
  end
end
