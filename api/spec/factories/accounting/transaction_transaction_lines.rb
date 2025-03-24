FactoryBot.define do
  factory :financial_transaction_line, class: 'Accounting::FinancialTransactionLine' do
    holder_id { SecureRandom.uuid }
    financial_transaction { nil }
    unit { "hours" }
    unit_price_amount { 100.00 }
    quantity { 1 }
    excl_tax_amount { 100.0 }
    tax_rate { 0.2 }
    group_id { nil }
  end
end
