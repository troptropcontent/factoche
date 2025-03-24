class CreateAccountingFinancialTransactionLines < ActiveRecord::Migration[8.0]
  def change
    create_table :accounting_financial_transaction_lines do |t|
      t.string :holder_id, null: false, index: true
      t.references :financial_transaction, null: false, foreign_key: { to_table: "accounting_financial_transactions" }
      t.string :unit, null: false
      t.decimal :unit_price_amount, null: false, precision: 15, scale: 2
      t.decimal :quantity, null: false, precision: 15, scale: 6
      t.decimal :tax_rate, null: false, precision: 15, scale: 2
      t.decimal :retention_guarantee_rate, null: false, precision: 15, scale: 2
      t.decimal :excl_tax_amount, null: false, precision: 15, scale: 2
      t.bigint :group_id
      t.timestamps

      t.index :group_id
    end
  end
end
