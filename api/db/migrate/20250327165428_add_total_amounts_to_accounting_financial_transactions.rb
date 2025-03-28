class AddTotalAmountsToAccountingFinancialTransactions < ActiveRecord::Migration[8.0]
  def change
    add_column :accounting_financial_transactions, :total_excl_tax_amount, :decimal, precision: 15, scale: 2, null: false
    add_column :accounting_financial_transactions, :total_including_tax_amount, :decimal, precision: 15, scale: 2, null: false
    add_column :accounting_financial_transactions, :total_excl_retention_guarantee_amount, :decimal, precision: 15, scale: 2, null: false
  end
end
