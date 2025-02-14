FactoryBot.define do
  factory :item, class: 'Organization::Item' do
    project_version { nil }
    item_group { nil }
    name { "Garde corps" }
    sequence(:position) { |n| n }
    description { "Trés beau garde coprs en galva" }
    quantity { 1 }
    unit { "unité" }
    unit_price_cents { 1 }
  end
end
