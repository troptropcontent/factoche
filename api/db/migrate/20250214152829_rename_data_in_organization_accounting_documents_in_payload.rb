class RenameDataInOrganizationAccountingDocumentsInPayload < ActiveRecord::Migration[8.0]
  def change
    rename_column :organization_accounting_documents, :data, :payload
  end
end
