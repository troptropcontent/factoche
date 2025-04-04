FactoryBot.define do
  factory :order, class: 'Organization::Order' do
    company { nil }
    client { nil }
    sequence(:number) { |n| n }
    sequence(:name) { |n| "Order #{n}" }
    trait :with_version do
      after(:create) { |order| create(:project_version, project: order) }
    end
  end
end
