FactoryBot.define do
  factory :quote, class: 'Organization::Quote' do
    company { nil }
    client { nil }
    sequence(:number) { |n| n }
    sequence(:name) { |n| "Quote #{n}" }
    sequence(:address_street) { |n| "10 Rue de la Paix Apt #{n}" }
    address_zipcode { "75002" }
    address_city { "Paris" }
    transient do
      version_number { 1 }
    end

    trait :with_version do
      after(:create) { |quote, evaluator| create(:project_version, project: quote, number: evaluator.version_number) }
    end
  end
end
