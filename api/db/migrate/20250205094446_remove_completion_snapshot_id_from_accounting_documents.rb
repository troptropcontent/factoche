class RemoveCompletionSnapshotIdFromAccountingDocuments < ActiveRecord::Migration[8.0]
  def change
    remove_reference :organization_accounting_documents, :completion_snapshot
  end
end
