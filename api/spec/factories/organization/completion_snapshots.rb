FactoryBot.define do
  factory :completion_snapshot, class: 'Organization::CompletionSnapshot' do
    project_version { nil }
    description { "MyString" }
    trait :with_invoice do
      after(:create) do |completion_snapshot|
        Organization::BuildInvoiceFromCompletionSnapshot.call(completion_snapshot, Time.current).save!
        completion_snapshot.reload
      end
    end
  end
end
