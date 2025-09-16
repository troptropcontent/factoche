class ChangeIbanAndBicToNotNullInFinancialTransactions < ActiveRecord::Migration[8.0]
  def change
    change_column_null :accounting_financial_transaction_details, :bank_detail_iban, false
    change_column_null :accounting_financial_transaction_details, :bank_detail_bic, false
  end
end
