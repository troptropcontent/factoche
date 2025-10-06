class ChangeAccountingFinancialTransactionDetailsPurchaseOrderNumberNull < ActiveRecord::Migration[8.0]
  def change
    change_column_null :accounting_financial_transaction_details, :purchase_order_number, true
  end
end
