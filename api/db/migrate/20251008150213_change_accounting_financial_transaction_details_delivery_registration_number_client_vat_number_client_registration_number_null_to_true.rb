class ChangeAccountingFinancialTransactionDetailsDeliveryRegistrationNumberClientVatNumberClientRegistrationNumberNullToTrue < ActiveRecord::Migration[8.0]
  def change
    change_column_null :accounting_financial_transaction_details, :client_registration_number, true
    change_column_null :accounting_financial_transaction_details, :client_vat_number, true
    change_column_null :accounting_financial_transaction_details, :delivery_registration_number, true
  end
end
