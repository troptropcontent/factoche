class ChangeTotalAmountFalseInOrganizationAccountingDocuments < ActiveRecord::Migration[8.0]
  def change
    change_column_null :organization_accounting_documents, :total_amount, false
  end
end
