class MoveReferenceBetweenCompletionSnapshotFromCompletionSnapshotToAccountingDocuments < ActiveRecord::Migration[8.0]
  def change
    add_reference :organization_accounting_documents, :completion_snapshot, foreign_key: { to_table: :organization_completion_snapshots }

    reversible do |dir|
      dir.up do
        # Copy existing references to the new column
        execute <<-SQL
          UPDATE organization_accounting_documents#{' '}
          SET completion_snapshot_id = (
            SELECT id FROM organization_completion_snapshots#{' '}
            WHERE organization_completion_snapshots.invoice_id = organization_accounting_documents.id#{' '}
            OR organization_completion_snapshots.credit_note_id = organization_accounting_documents.id
          )
        SQL

        remove_reference :organization_completion_snapshots, :invoice, foreign_key: { to_table: :organization_accounting_documents }
        remove_reference :organization_completion_snapshots, :credit_note, foreign_key: { to_table: :organization_accounting_documents }
      end

      dir.down do
        add_reference :organization_completion_snapshots, :invoice, foreign_key: { to_table: :organization_accounting_documents }
        add_reference :organization_completion_snapshots, :credit_note, foreign_key: { to_table: :organization_accounting_documents }

        # Restore the old references
        execute <<-SQL
          UPDATE organization_completion_snapshots
          SET invoice_id = (
            SELECT id FROM organization_accounting_documents#{' '}
            WHERE organization_accounting_documents.completion_snapshot_id = organization_completion_snapshots.id
            AND organization_accounting_documents.type = 'Organization::Invoice'
          ),
          credit_note_id = (
            SELECT id FROM organization_accounting_documents#{' '}
            WHERE organization_accounting_documents.completion_snapshot_id = organization_completion_snapshots.id
            AND organization_accounting_documents.type = 'Organization::CreditNote'
          )
        SQL
      end
    end
  end
end
