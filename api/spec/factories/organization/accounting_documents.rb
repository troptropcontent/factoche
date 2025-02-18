FactoryBot.define do
  factory :accounting_document, class: 'Organization::AccountingDocument' do
    completion_snapshot { nil }
    pdf { nil }
    xml { nil }
    sequence(:number) { |n| "DOC-#{n}" }
    issue_date { Time.current }
    delivery_date { Time.current }
    tax_amount { BigDecimal("10.00") }
    retention_guarantee_amount { BigDecimal("0.00") }
    payload { {} }
    total_excl_tax_amount { BigDecimal("100.00") }
    due_date { Time.current + 30.days }

    factory :invoice, class: 'Organization::Invoice'
    factory :credit_note, class: 'Organization::CreditNote'
  end
end
