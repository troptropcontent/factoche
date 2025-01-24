FactoryBot.define do
  factory :accounting_document, class: 'Organization::AccountingDocument' do
    completion_snapshot { nil }
    pdf { nil }
    xml { nil }
    total_amount_cents { 1 }
    date { "2025-01-24 09:58:40" }

    factory :invoice, class: 'Organization::Invoice'
    factory :credit_note, class: 'Organization::CreditNote'
  end
end
