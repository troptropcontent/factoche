FactoryBot.define do
  factory :draft_order, class: 'Organization::DraftOrder' do
    company { nil }
    client { nil }
    sequence(:number) { |n| n }
    sequence(:name) { |n| "DraftOrder #{n}" }
    trait :with_version do
      after(:create) { |draft_order| create(:project_version, project: draft_order) }
    end
  end
end
