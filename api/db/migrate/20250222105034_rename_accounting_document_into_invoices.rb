class RenameAccountingDocumentIntoInvoices < ActiveRecord::Migration[8.0]
  def change
    remove_column :organization_accounting_documents, :type, :string
    rename_table :organization_accounting_documents, :organization_invoices
  end
end
