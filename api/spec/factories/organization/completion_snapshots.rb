FactoryBot.define do
  factory :completion_snapshot, class: 'Organization::CompletionSnapshot' do
    project_version { nil }
    description { "MyString" }
    transient do
      invoice_issue_date { Time.current }
      invoice_status { "draft" }
    end
    trait :with_invoice do
      after(:create) do |completion_snapshot, evaluator|
        invoice = Organization::BuildInvoiceFromCompletionSnapshot.call(completion_snapshot, evaluator.invoice_issue_date)
        invoice.status = evaluator.invoice_status if evaluator.invoice_status
        invoice.save!
        completion_snapshot.reload
      end
    end
  end
end
