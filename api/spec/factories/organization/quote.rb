FactoryBot.define do
  factory :quote, class: 'Organization::Quote' do
    company { nil }
    client { nil }
    sequence(:number) { |n| n }
    sequence(:name) { |n| "Quote #{n}" }
    trait :with_version do
      after(:create) { |quote| create(:project_version, project: quote) }
    end
  end
end
