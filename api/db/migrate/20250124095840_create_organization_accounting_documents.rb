class CreateOrganizationAccountingDocuments < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_accounting_documents do |t|
      t.references :completion_snapshot, null: false, foreign_key: { to_table: "organization_completion_snapshots" }
      t.string :type, null: false
      t.integer :total_amount_cents, null: false
      t.datetime :date, null: false

      t.timestamps
    end
  end
end
