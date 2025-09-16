FactoryBot.define do
  factory :bank_detail, class: 'Organization::BankDetail' do
    association :company, factory: :company
    name { |n| "Bank Account #{n.to_s.rjust(2, '0')}" }
    sequence(:iban) { |n| "FR#{n.to_s.rjust(2, '0')}12345678901234567890" }
    bic { "BNPAFRPP" }
  end
end
