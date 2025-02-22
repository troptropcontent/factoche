class AddStatusToOrganizationAccountingDocuments < ActiveRecord::Migration[8.0]
  def change
    create_enum :invoice_status, [ "draft", "published", "cancelled" ]
    add_column :organization_accounting_documents, :status, :enum, enum_type: :invoice_status, null: false, default: :draft
  end
end
