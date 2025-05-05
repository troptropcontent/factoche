class AddAClientIdToFinancialTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :accounting_financial_transactions, :client_id, :bigint, null: false
    add_index :accounting_financial_transactions, :client_id
  end
end
