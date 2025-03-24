class RemoveIrrelevantColumnsFromAccountingDocuments < ActiveRecord::Migration[8.0]
  def change
    remove_column :organization_accounting_documents, :total_amount_cents, :integer
    remove_column :organization_accounting_documents, :date, :datetime
    remove_column :organization_accounting_documents, :total_amount_incl_tax, :decimal
    remove_column :organization_accounting_documents, :total_amount_excl_tax, :decimal

    add_column :organization_accounting_documents, :total_excl_tax_amount, :decimal, precision: 15, scale: 2, null: false
    add_column :organization_accounting_documents, :due_date, :datetime
  end
end
