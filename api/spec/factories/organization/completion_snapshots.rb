FactoryBot.define do
  factory :completion_snapshot, class: 'Organization::CompletionSnapshot' do
    project_version { nil }
    description { "MyString" }
    transient do
      invoice_issue_date { Time.current }
    end
    trait :with_invoice do
      after(:create) do |completion_snapshot, evaluator|
        Organization::BuildInvoiceFromCompletionSnapshot.call(completion_snapshot, evaluator.invoice_issue_date).save!
        completion_snapshot.reload
      end
    end
  end
end
