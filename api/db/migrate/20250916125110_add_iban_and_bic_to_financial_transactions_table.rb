class AddIbanAndBicToFinancialTransactionsTable < ActiveRecord::Migration[8.0]
  def change
    add_column :accounting_financial_transaction_details, :bank_detail_iban, :string, null: true
    add_column :accounting_financial_transaction_details, :bank_detail_bic, :string, null: true
  end
end
