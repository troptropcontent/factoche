class AddInvoiceIdAndCreditNoteIdToOrganizationCompletionSnapshots < ActiveRecord::Migration[8.0]
  def change
    add_reference :organization_completion_snapshots, :invoice, null: false, foreign_key: { to_table: "organization_accounting_documents" }, null: true
    add_reference :organization_completion_snapshots, :credit_note, null: false, foreign_key: { to_table: "organization_accounting_documents" }, null: true
  end
end
