class AddPhoneAndEmailToInvoiceDetails < ActiveRecord::Migration[8.0]
  def change
    add_column :accounting_financial_transaction_details, :seller_phone, :string, null: false
    add_column :accounting_financial_transaction_details, :seller_email, :string, null: false
    add_column :accounting_financial_transaction_details, :client_phone, :string, null: false
    add_column :accounting_financial_transaction_details, :client_email, :string, null: false
    add_column :accounting_financial_transaction_details, :delivery_phone, :string, null: false
    add_column :accounting_financial_transaction_details, :delivery_email, :string, null: false
  end
end
