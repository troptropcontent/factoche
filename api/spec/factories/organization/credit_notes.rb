FactoryBot.define do
  factory :credit_note, class: 'Organization::CreditNote' do
    status { "draft" }
    original_invoice { nil }
    sequence(:number) { |n| "AV-#{n}" }
    issue_date { Time.current }
    tax_amount { BigDecimal("10.00") }
    retention_guarantee_amount { BigDecimal("0.00") }
    payload { {} }
    total_excl_tax_amount { BigDecimal("100.00") }
    total_amount { BigDecimal("110.00") }
  end
end
