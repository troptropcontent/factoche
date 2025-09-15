FactoryBot.define do
  factory :quote, class: 'Organization::Quote' do
    company { nil }
    client { nil }
    sequence(:number) { |n| n }
    sequence(:name) { |n| "Quote #{n}" }
    sequence(:address_street) { |n| "10 Rue de la Paix Apt #{n}" }
    address_zipcode { "75002" }
    address_city { "Paris" }
    trait :with_version do
      after(:create) { |quote| create(:project_version, project: quote, bank_detail: quote.company.bank_details.last) }
    end
  end
end
