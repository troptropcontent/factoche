class CreateTheOrganizationCreditNotesTable < ActiveRecord::Migration[8.0]
  def change
    create_enum :credit_note_status, [ "draft", "published" ]
    create_table :organization_credit_notes do |t|
      t.string :number, null: false
      t.datetime :issue_date, null: false
      t.decimal :tax_amount, precision: 15, scale: 2, null: false
      t.decimal :retention_guarantee_amount, precision: 15, scale: 2, default: "0.0", null: false
      t.jsonb :payload, default: {}, null: false
      t.decimal :total_excl_tax_amount, precision: 15, scale: 2, null: false
      t.decimal :total_amount, null: false
      t.enum :status, default: "draft", null: false, enum_type: "credit_note_status"
      t.references :original_invoice, foreign_key: { to_table: "organization_invoices" }
      t.timestamps

      t.index [ "payload" ], name: "index_organization_credit_notes_on_payload", using: :gin
    end
  end
end
