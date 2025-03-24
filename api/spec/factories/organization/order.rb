FactoryBot.define do
  factory :order, class: 'Organization::Order' do
    company { nil }
    client { nil }
    sequence(:number) { |n| n }
    sequence(:name) { |n| "Order #{n}" }
  end
end
