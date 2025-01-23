class CreateOrganizationCompletionSnapshotItems < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_completion_snapshot_items do |t|
      t.references :item, null: false, foreign_key: { to_table: "organization_items" }
      t.references :completion_snapshot, null: false, foreign_key: { to_table: "organization_completion_snapshots" }
      t.decimal :completion_percentage, null: false

      t.timestamps
    end
  end
end
