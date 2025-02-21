class AddStatusToOrganizationAccountingDocuments < ActiveRecord::Migration[8.0]
  def change
    create_enum :status, [ "draft", "published", "posted" ]
    add_column :organization_accounting_documents, :status, :enum, enum_type: :status, null: false, default: :draft
  end
end
