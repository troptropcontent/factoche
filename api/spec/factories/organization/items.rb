FactoryBot.define do
  factory :item, class: 'Organization::Item' do
    holder { nil }
    name { "Garde corps" }
    description { "Trés beau garde coprs en galva" }
    quantity { 1 }
    unit { "unité" }
    unit_price_cents { 1 }
  end
end
