# rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
FactoryBot.define do
  factory :accounting_project_version_hash, class: "Hash" do
    number { 1 }
    created_at { 1.day.ago }
    retention_guarantee_rate { 0.1 }
    items {
      [
        {
          original_item_uuid: 'item-uuid-1',
          group_id: 1,
          name: 'Item 1',
          description: 'Description 1',
          quantity: 2,
          unit: 'pieces',
          unit_price_amount: 100.0,
          tax_rate: 0.2
        }
      ]
    }
    item_groups {
      [
        {
          id: 1,
          name: 'Group 1',
          description: 'Group Description'
        }
      ]
    }

    skip_create
    initialize_with { attributes }
  end
end
# rubocop:enable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
