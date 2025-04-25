FactoryBot.define do
  factory :order, class: 'Organization::Order' do
    company { nil }
    client { nil }
    sequence(:number) { |n| n }
    sequence(:name) { |n| "Order #{n}" }
    trait :with_version do
      after(:create) { |order|
        version = create(:project_version, project: order)

        [ "first", "second", "third" ].each_with_index do |ordinal, index|
          FactoryBot.create(
            :item,
            project_version: version,
            name: "#{ordinal.capitalize} Item",
            quantity: (index + 1) * 10,
            unit_price_amount: (index + 1) * 10,
            unit: "U",
            original_item_uuid: SecureRandom.uuid
            )
        end
    }
    end
  end
end
