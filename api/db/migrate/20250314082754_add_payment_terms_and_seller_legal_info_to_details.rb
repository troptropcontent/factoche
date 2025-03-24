class AddPaymentTermsAndSellerLegalInfoToDetails < ActiveRecord::Migration[8.0]
  def change
    add_column :accounting_financial_transaction_details, :seller_legal_form, :enum, enum_type: :legal_form, null: false
    add_column :accounting_financial_transaction_details, :seller_capital_amount, :decimal, precision: 10, scale: 2, null: false
    add_column :accounting_financial_transaction_details, :seller_rcs_city, :string, null: false
    add_column :accounting_financial_transaction_details, :seller_rcs_number, :string, null: false
    add_column :accounting_financial_transaction_details, :payment_term_days, :integer, null: false
    add_column :accounting_financial_transaction_details, :payment_term_accepted_methods, :string, array: true, null: false, default: []
  end
end
