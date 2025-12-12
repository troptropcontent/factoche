# rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
FactoryBot.define do
  factory :accounting_project_version_item_hash, class: 'Hash' do
    sequence(:original_item_uuid) { |n| "item-uuid-#{n}" }
    sequence(:name) { |n| "Item #{n}" }
    sequence(:description) { |n| "Description #{n}" }
    quantity { 2 }
    unit { 'pieces' }
    unit_price_amount { 100.0 }
    tax_rate { 0.2 }

    skip_create
    initialize_with { attributes }
  end
  factory :accounting_project_version_item_group_hash, class: 'Hash' do
    sequence(:name) { |n| "Item Group #{n}" }
    sequence(:description) { |n| "Item Group Description #{n}" }

    skip_create
    initialize_with { attributes }
  end

  factory :accounting_project_version_discount_hash, class: 'Hash' do
    sequence(:original_discount_uuid) { |n| "discount-uuid-#{n}" }
    kind { 'percentage' }
    value { 0.1 }
    amount { 20.0 }
    sequence(:position)  { |n| n }
    name { 'Test Discount' }

    skip_create
    initialize_with { attributes }
  end

  factory :accounting_project_version_hash, class: "Hash" do
    transient do
      item_group_ids { [] }
    end
    transient do
      item_count { 1 }
    end
    transient do
      discount_count { 0 }
    end

    number { 1 }
    created_at { 1.day.ago }
    retention_guarantee_rate { 0.1 }
    items { build_list(:accounting_project_version_item_hash, item_count) { |item_hash, index|
      item_hash[:group_id] = item_group_ids[index] ? item_group_ids[index] : nil
    } }
    item_groups { build_list(:accounting_project_version_item_group_hash, item_group_ids.uniq.length) { |item_group_hash, index|
      item_group_hash[:id] = item_group_ids[index] if item_group_ids[index]
    } }
    discounts { build_list(:accounting_project_version_discount_hash, discount_count) }

    skip_create
    initialize_with { attributes }
  end
end
# rubocop:enable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
