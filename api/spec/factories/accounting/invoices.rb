# rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
FactoryBot.define do
  factory :invoice, class: "Accounting::Invoice" do
    issue_date { Time.current }
    status { "draft" }

    context do
      {
        project_version_retention_guarantee_rate: BigDecimal("0.05"),
        project_version_number: 1,
        project_version_date: Time.current.to_s,
        project_total_amount: BigDecimal("1000.00"),
        project_total_previously_billed_amount: BigDecimal("0.00"),
        project_version_items: [
          {
            original_item_uuid: SecureRandom.uuid,
            group_id: 1,
            name: "Item 1",
            description: "Description for item 1",
            quantity: 10,
            unit: "hours",
            unit_price_amount: BigDecimal("100.00"),
            tax_rate: BigDecimal("0.20"),
            previously_billed_amount: BigDecimal("0.00")
          }
        ],
        project_version_item_groups: [
          {
            id: 1,
            name: "Group 1",
            description: "Description for group 1"
          }
        ]
      }
    end

    trait :posted do
      status { "posted" }
    end

    trait :cancelled do
      status { "cancelled" }
    end

    trait :voided do
      status { "voided" }
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
