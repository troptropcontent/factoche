FactoryBot.define do
  factory :draft_order, class: 'Organization::DraftOrder' do
    company { nil }
    client { nil }
    sequence(:number) { |n| n }
    sequence(:name) { |n| "DraftOrder #{n}" }
    sequence(:address_street) { |n| "10 Rue de la Paix Apt #{n}" }
    address_zipcode { "75002" }
    address_city { "Paris" }
    trait :with_version do
      after(:create) { |draft_order| create(:project_version, project: draft_order, bank_detail: draft_order.company.bank_details.last) }
    end
  end
end
