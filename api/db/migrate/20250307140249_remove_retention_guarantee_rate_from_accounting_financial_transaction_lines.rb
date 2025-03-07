class RemoveRetentionGuaranteeRateFromAccountingFinancialTransactionLines < ActiveRecord::Migration[8.0]
  def change
    remove_column :accounting_financial_transaction_lines, :retention_guarantee_rate, :decimal, precision: 15, scale: 2, null: false
  end
end
