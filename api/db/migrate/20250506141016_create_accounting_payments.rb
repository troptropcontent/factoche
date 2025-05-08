class CreateAccountingPayments < ActiveRecord::Migration[8.0]
  def change
    create_table :accounting_payments do |t|
      t.references :invoice, null: false, foreign_key: { to_table: :accounting_financial_transactions }
      t.decimal :amount, null: false
      t.datetime :received_at, null: false

      t.timestamps
    end
  end
end
