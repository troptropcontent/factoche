class CreateAccountingFinancialTransactions < ActiveRecord::Migration[8.0]
  def change
    create_enum :accounting_financial_transaction_status, [ "draft", "voided", "posted", "cancelled" ]
    create_table :accounting_financial_transactions do |t|
      t.bigint :company_id, null: false, index: true
      t.bigint :holder_id, null: false, index: true
      t.enum :status, enum_type: :accounting_financial_transaction_status, default: "draft", null: false
      t.string :number
      t.string :type, null: false
      t.datetime :issue_date, null: false
      t.jsonb :context, null: false, default: {}
      t.timestamps
      t.index :context, using: :gin
    end
  end
end
