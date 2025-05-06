FactoryBot.define do
  factory :accounting_payment, class: 'Accounting::Payment' do
    invoice { nil }
    amount { "9.99" }
    received_at { "2025-05-06 14:10:17" }
  end
end
