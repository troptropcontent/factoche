FactoryBot.define do
  factory :financial_transaction_detail, class: 'Accounting::FinancialTransactionDetail' do
    financial_transaction { nil }

    delivery_date { Date.current }
    due_date { Date.current + 30.days }

    seller_name { "Seller Company" }
    seller_registration_number { "REG123456" }
    seller_address_zipcode { "12345" }
    seller_address_street { "123 Seller St" }
    seller_address_city { "Seller City" }
    seller_vat_number { "VAT123456" }

    client_name { "Client Company" }
    client_registration_number { "CLI123456" }
    client_address_zipcode { "54321" }
    client_address_street { "456 Client St" }
    client_address_city { "Client City" }
    client_vat_number { "VAT654321" }

    delivery_name { "Delivery Company" }
    delivery_registration_number { "DEL123456" }
    delivery_address_zipcode { "67890" }
    delivery_address_street { "789 Delivery St" }
    delivery_address_city { "Delivery City" }

    purchase_order_number { "PO#{SecureRandom.hex(4).upcase}" }
  end
end
