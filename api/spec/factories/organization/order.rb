FactoryBot.define do
  factory :order, class: 'Organization::Order' do
    client { nil }
    sequence(:name) { |n| "Order #{n}" }
  end
end
