class DropOrganizationCompletionSnapshotsAndOrganizationCompletionSnapshotItems < ActiveRecord::Migration[8.0]
  def change
    drop_table :organization_credit_notes
    drop_table :organization_invoices
    drop_table :organization_completion_snapshot_items
    drop_table :organization_completion_snapshots
  end
end
