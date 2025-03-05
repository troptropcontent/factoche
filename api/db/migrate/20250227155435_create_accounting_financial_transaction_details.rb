class CreateAccountingFinancialTransactionDetails < ActiveRecord::Migration[8.0]
  def change
    create_table :accounting_financial_transaction_details do |t|
      t.references :financial_transaction, null: false, foreign_key: { to_table: "accounting_financial_transactions" }
      t.datetime :delivery_date, null: false
      t.string :seller_name, null: false
      t.string :seller_registration_number, null: false
      t.string :seller_address_zipcode, null: false
      t.string :seller_address_street, null: false
      t.string :seller_address_city, null: false
      t.string :seller_vat_number, null: false
      t.string :client_name, null: false
      t.string :client_registration_number, null: false
      t.string :client_address_zipcode, null: false
      t.string :client_address_street, null: false
      t.string :client_address_city, null: false
      t.string :client_vat_number, null: false
      t.string :delivery_name, null: false
      t.string :delivery_registration_number, null: false
      t.string :delivery_address_zipcode, null: false
      t.string :delivery_address_street, null: false
      t.string :delivery_address_city, null: false
      t.string :purchase_order_number, null: false
      t.datetime :due_date, null: false
      t.timestamps
    end
  end
end
