FactoryBot.define do
  factory :project, class: 'Organization::Project' do
    client { nil }
    sequence(:name) { |n| "Project #{n}" }
    sequence(:address_street) { |n| "10 Rue de la Paix Apt #{n}" }
    address_zipcode { "75002" }
    address_city { "Paris" }
    sequence(:number) { |n| n }
  end
end
