FactoryBot.define do
  factory :completion_snapshot, class: 'Organization::CompletionSnapshot' do
    project_version { nil }
    description { "MyString" }
    trait :with_invoice do
      after(:create) do |completion_snapshot|
        create(:invoice, completion_snapshot: completion_snapshot)
      end
    end
  end
end
