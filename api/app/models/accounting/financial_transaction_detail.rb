class Accounting::FinancialTransactionDetail < ApplicationRecord
  belongs_to :financial_transaction, class_name: "Accounting::FinancialTransaction"
  validates :delivery_date,
            :seller_name,
            :seller_registration_number,
            :seller_address_zipcode,
            :seller_address_street,
            :seller_address_city,
            :seller_vat_number,
            :client_name,
            :client_address_zipcode,
            :client_address_street,
            :client_address_city,
            :delivery_name,
            :delivery_address_zipcode,
            :delivery_address_street,
            :delivery_address_city,
            :due_date,
            presence: true
end
