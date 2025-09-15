require 'rails_helper'

module Organization
  module Quotes
    # rubocop:disable RSpec/ExampleLength, RSpec/MultipleMemoizedHelpers
    RSpec.describe ConvertToDraftOrder do
      describe '.call', :aggregate_failures do
        let(:company) { FactoryBot.create(:company, :with_bank_detail) }
        let(:client) { FactoryBot.create(:client, company: company) }
        let(:quote) { FactoryBot.create(:quote, client: client, company: company) }
        let!(:quote_version) { FactoryBot.create(:project_version, project: quote, bank_detail: company.bank_details.last) }

        context 'when successful' do
          before {  # Create groups
          group1 = FactoryBot.create(:item_group,
            project_version: quote_version,
            name: "Group 1",
            position: 0
          )
          group2 = FactoryBot.create(:item_group,
            project_version: quote_version,
            name: "Group 2",
            position: 1
          )

          # Create items in groups
          FactoryBot.create(:item,
            project_version: quote_version,
            item_group: group1,
            name: "Item 1",
            quantity: 1,
            unit: "DAY",
            unit_price_amount: 100.00,
            position: 0,
            tax_rate: 0.20
          )
          FactoryBot.create(:item,
            project_version: quote_version,
            item_group: group2,
            name: "Item 2",
            quantity: 2,
            unit: "HOUR",
            unit_price_amount: 50.00,
            position: 0,
            tax_rate: 0.20
          )

          # Create standalone item
          FactoryBot.create(:item,
            project_version: quote_version,
            name: "Standalone Item",
            quantity: 1,
            unit: "UNIT",
            unit_price_amount: 75.00,
            position: 0,
            tax_rate: 0.20
          ) }

          it 'creates an order with the same structure as the quote' do
            result = described_class.call(quote.id)

            expect(result).to be_success
            order = result.data
            order_version = order.versions.first

            # Check basic attributes
            expect(order).to be_a(DraftOrder)
            expect(order.client).to eq(quote.client)
            expect(order.name).to eq(quote.name)
            expect(order.original_project_version).to eq(quote_version)

            # Check version attributes
            expect(order_version.retention_guarantee_rate).to eq(quote_version.retention_guarantee_rate)
            expect(order_version.number).to eq(1)

            # Check groups
            expect(order_version.item_groups.count).to eq(quote_version.item_groups.count)
            expect(order_version.item_groups.map(&:name)).to match_array(quote_version.item_groups.map(&:name))

            # Check items
            expect(order_version.items.count).to eq(quote_version.items.count)
            expect(order_version.items.map(&:name)).to match_array(quote_version.items.map(&:name))
          end

          it 'enqueue a new job to generate its pdf' do
            expect { described_class.call(quote.id) }
            .to change(Organization::ProjectVersions::GeneratePdfJob.jobs, :size).by(1)
          end

          it 'preserves all item attributes' do
            result = described_class.call(quote.id)
            order_version = result.data.versions.first

            quote_version.items.each do |quote_item|
              order_item = order_version.items.find_by(name: quote_item.name)

              expect(order_item.quantity).to eq(quote_item.quantity)
              expect(order_item.unit).to eq(quote_item.unit)
              expect(order_item.unit_price_amount).to eq(quote_item.unit_price_amount)
              expect(order_item.position).to eq(quote_item.position)
              expect(order_item.tax_rate).to eq(quote_item.tax_rate)
            end
          end
        end

        context 'when quote not found' do
          it 'returns failure' do
            result = described_class.call(-1)
            expect(result).to be_failure
            expect(result.error).to include("Failed to convert quote to draft order: Couldn't find Organization::Quote with 'id'=-1")
          end
        end

        context 'when quote have already been converted' do
          before { described_class.call(quote.id) }

          it 'returns failure' do
            result = described_class.call(quote.id)
            expect(result).to be_failure
            expect(result.error).to include("Failed to convert quote to draft order: Quote has already been converted to an draft order")
          end
        end

        context 'when transaction fails' do
          it 'rolls back all changes on error' do
            allow(DraftOrder).to receive(:create!).and_raise(StandardError, "Test error")

            expect {
              described_class.call(quote_version.id)
            }.not_to change(DraftOrder, :count)
          end
        end
      end
    end
    # rubocop:enable RSpec/ExampleLength, RSpec/MultipleMemoizedHelpers
  end
end
