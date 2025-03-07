FactoryBot.define do
  factory :item, class: 'Organization::Item' do
    project_version { nil }
    original_item_uuid { SecureRandom.uuid }
    item_group { nil }
    sequence(:name) { |n| "Garde corps #{n}" }
    sequence(:position) { |n| n }
    description { "Trés beau garde coprs en galva" }
    quantity { 1 }
    unit { "unité" }
    unit_price_cents { 1 }
    tax_rate { 0.2 }
  end
end
