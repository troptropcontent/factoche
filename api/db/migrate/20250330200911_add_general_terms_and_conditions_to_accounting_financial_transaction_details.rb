class AddGeneralTermsAndConditionsToAccountingFinancialTransactionDetails < ActiveRecord::Migration[8.0]
  def change
    add_column :accounting_financial_transaction_details, :general_terms_and_conditions, :text
  end
end
