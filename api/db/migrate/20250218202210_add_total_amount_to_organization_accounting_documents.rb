class AddTotalAmountToOrganizationAccountingDocuments < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_accounting_documents, :total_amount, :decimal
  end
end
