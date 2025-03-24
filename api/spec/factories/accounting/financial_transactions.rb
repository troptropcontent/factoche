# rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
FactoryBot.define do
  factory :financial_transaction, class: 'Accounting::FinancialTransaction' do
    company_id { nil }
    holder_id { nil }
    status { :draft }
    sequence(:number) { |n| status == :draft ? nil : "INV-2025-#{n.to_s.rjust(6, '0')}" }
    issue_date { Time.current }

    factory :completion_snapshot_invoice, class: 'Accounting::CompletionSnapshotInvoice' do
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
    end
  end
end
# rubocop:enable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
