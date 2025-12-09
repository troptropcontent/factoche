require 'rails_helper'

module Accounting
  module Proformas
    # rubocop:disable RSpec/MultipleMemoizedHelpers
    RSpec.describe BuildAttributes do
      describe '.call' do
        subject(:result) { described_class.call(args) }

        let(:args) { {
          company_id: company[:id],
          client_id: client[:id],
          issue_date: issue_date,
          snapshot_number: snapshot_number,
          project: project,
          project_version: project_version,
          new_invoice_items: new_invoice_items
        }}

        let(:snapshot_number) { 1 }
        let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company[:id]) }

        let(:issue_date) { Time.current }


        let(:new_invoice_items) do
          [
            { original_item_uuid: 'item-uuid-1', invoice_amount: "150" }
          ]
        end

        let(:project) { FactoryBot.build(:accounting_project_hash) }

        let(:company) { FactoryBot.build(:accounting_company_hash, id: 1) }

        let(:client) { FactoryBot.build(:accounting_client_hash, id: 1) }

        let(:project_version) { FactoryBot.build(:accounting_project_version_hash, id: 123, item_group_ids: [ 1 ]) }

        let(:previous_invoice_first_item_amount) { 50 }

        before do
          # Create a previously posted invoice for the item
          creation_service_result = Create.call(
            company:,
            client:,
            project:,
            project_version:,
            new_invoice_items: [ {
              original_item_uuid: 'item-uuid-1',
              invoice_amount: previous_invoice_first_item_amount
            } ],
            snapshot_number: 1,
            issue_date: 2.days.ago
          )

          raise creation_service_result.error if creation_service_result.failure?

          Accounting::Proformas::Post.call(creation_service_result.data.id)
        end

        it 'is a success' do
          expect(result).to be_success
        end

        # rubocop:disable RSpec/ExampleLength
        it 'returns success with correct invoice attributes', :aggregate_failures do
          expect(result.data).to include(
            company_id: company[:id],
            client_id: client[:id],
            holder_id: project_version[:id],
            status: :draft,
            issue_date: issue_date,
            total_excl_tax_amount: 150.0,
            total_including_tax_amount: 180.0,
            total_excl_retention_guarantee_amount: 162.0
          )

          context = result.data[:context]
          expect(context).to include(
            project_version_number: 1,
            project_version_date: project_version[:created_at].iso8601,
            project_version_retention_guarantee_rate: 0.1,
            project_total_amount: 200.0.to_d, # 2 * 100.0
            project_total_previously_billed_amount: 50.0.to_d # From the previous transaction
          )

          expect(context[:project_version_items].first).to include(
            original_item_uuid: 'item-uuid-1',
            previously_billed_amount: 50.0.to_d
          )

          expect(context[:project_version_item_groups].first).to include(
            id: 1,
            name: "Item Group 1",
            description: "Item Group Description 1"
          )

          expect(context[:project_version_discounts]).to eq([])
        end

        context 'when project version has discounts' do
          let(:project_version) {
            FactoryBot.build(
              :accounting_project_version_hash,
              id: 123,
              item_group_ids: [ 1 ],
              discount_count: 2
            )
          }

          it 'returns success with discounts in context and discounted totals', :aggregate_failures do
            # Project items total: 200€ (2 items × 100€)
            # Discounts total: 40€ (2 × 20€)
            # Project total after discounts (net): 160€ (200 - 40)
            # Invoice amount before discount: 150€
            # Invoice proportion: 150/200 = 0.75 (calculated on gross amount)
            # Prorated discount: 40 × 0.75 = 30€
            # Invoice amount after discount: 150 - 30 = 120€
            # Tax (20%): 120 × 0.2 = 24€
            # Total including tax: 144€
            # Retention guarantee (10%): 144 × 0.1 = 14.4€
            # Total excl retention: 144 - 14.4 = 129.6€

            expect(result.data).to include(
              total_excl_tax_amount: 120.0,
              total_including_tax_amount: 144.0,
              total_excl_retention_guarantee_amount: 129.6
            )

            context = result.data[:context]
            # Verify project_total_amount is the NET amount (after discounts) for display
            expect(context[:project_total_amount]).to eq(160.0) # 200 - 40
            # Verify project_total_amount_before_discounts is the GROSS amount for calculations
            expect(context[:project_total_amount_before_discounts]).to eq(200.0)

            expect(context[:project_version_discounts].length).to eq(2)
            expect(context[:project_version_discounts].first).to include(
              original_discount_uuid: 'discount-uuid-1',
              kind: 'percentage',
              value: 0.1,
              amount: 20.0,
              position: 1,
              name: 'Test Discount'
            )
          end
        end

        context 'when there are multiple previous invoices' do
          before do
            # Create a second previous invoice for the same item
            creation_service_result = Create.call(
              company:,
              client:,
              project:,
              project_version:,
              new_invoice_items: [ {
                original_item_uuid: 'item-uuid-1',
                invoice_amount: 30
              } ],
              snapshot_number: 2,
              issue_date: 1.day.ago
            )

            raise creation_service_result.error if creation_service_result.failure?

            Accounting::Proformas::Post.call(creation_service_result.data.id)
          end

          it 'calculates correct previously billed amount from all previous invoices', :aggregate_failures do
            context = result.data[:context]

            # Previous invoices: 50 + 30 = 80
            expect(context[:project_total_previously_billed_amount]).to eq(80.0)

            expect(context[:project_version_items].first).to include(
              original_item_uuid: 'item-uuid-1',
              previously_billed_amount: 80.0
            )
          end
        end

        context 'when there is a credit note' do
          before do
            # Create an invoice and then cancel it (creating a credit note)
            creation_service_result = Create.call(
              company:,
              client:,
              project:,
              project_version:,
              new_invoice_items: [ {
                original_item_uuid: 'item-uuid-1',
                invoice_amount: 30
              } ],
              snapshot_number: 2,
              issue_date: 1.day.ago
            )

            raise creation_service_result.error if creation_service_result.failure?

            invoice = Accounting::Proformas::Post.call(creation_service_result.data.id).data

            # Cancel the invoice (creates a credit note)
            Accounting::Invoices::Cancel.call(invoice.id)
          end

          it 'subtracts credit note amount from previously billed amount', :aggregate_failures do
            context = result.data[:context]

            # Previous invoices: 50 + 30 - 30 (credit note) = 50
            expect(context[:project_total_previously_billed_amount]).to eq(50.0)

            expect(context[:project_version_items].first).to include(
              original_item_uuid: 'item-uuid-1',
              previously_billed_amount: 50.0
            )
          end
        end

        context 'when project has multiple items with different previous billing' do
          let(:project_version) {
            FactoryBot.build(
              :accounting_project_version_hash,
              id: 123,
              item_group_ids: [ 1 ],
              item_count: 3 # This creates 3 items with UUIDs: item-uuid-1, item-uuid-2, item-uuid-3
            )
          }

          let(:new_invoice_items) do
            [
              { original_item_uuid: 'item-uuid-1', invoice_amount: "50" },
              { original_item_uuid: 'item-uuid-2', invoice_amount: "75" },
              { original_item_uuid: 'item-uuid-3', invoice_amount: "100" }
            ]
          end

          before do
            # Create previous invoice only for item-uuid-2
            creation_service_result = Create.call(
              company:,
              client:,
              project:,
              project_version:,
              new_invoice_items: [ {
                original_item_uuid: 'item-uuid-2',
                invoice_amount: 40
              } ],
              snapshot_number: 2,
              issue_date: 1.day.ago
            )

            raise creation_service_result.error if creation_service_result.failure?

            Accounting::Proformas::Post.call(creation_service_result.data.id)
          end

          it 'tracks previously billed amounts separately for each item', :aggregate_failures do
            context = result.data[:context]

            # Total project amount: 3 items × 2 quantity × 100 unit_price = 600
            expect(context[:project_total_amount]).to eq(600.0)

            # Total previously billed: 50 (original before block) + 40 (item-uuid-2) = 90
            expect(context[:project_total_previously_billed_amount]).to eq(90.0)

            item_1 = context[:project_version_items].find { |i| i[:original_item_uuid] == 'item-uuid-1' }
            item_2 = context[:project_version_items].find { |i| i[:original_item_uuid] == 'item-uuid-2' }
            item_3 = context[:project_version_items].find { |i| i[:original_item_uuid] == 'item-uuid-3' }

            expect(item_1[:previously_billed_amount]).to eq(50.0) # From original before block
            expect(item_2[:previously_billed_amount]).to eq(40.0) # From this context's before block
            expect(item_3[:previously_billed_amount]).to eq(0.0)  # No previous billing
          end
        end

        context 'when discounts have previous billing' do
          let(:previous_invoice_first_item_amount) { 2500 }

          let(:project_version) {
            FactoryBot.build(
              :accounting_project_version_hash,
              id: 123,
              items: [
                FactoryBot.build(:accounting_project_version_item_hash,
                  unit_price_amount: 100,
                  quantity: 50,
                  group_id: 1,
                ),
                FactoryBot.build(:accounting_project_version_item_hash,
                  unit_price_amount: 100,
                  quantity: 2,
                  group_id: 1,
                )
              ],
              discounts: [
                FactoryBot.build(:accounting_project_version_discount_hash,
                  kind: "percentage",
                  value: 0.25,
                  amount: 1300 # (200 + 5000) % 25%
                ),
                FactoryBot.build(:accounting_project_version_discount_hash,
                  kind: "fixed_amount",
                  value: 1000,
                  amount: 1000
                )
              ]
            )
          }

          it 'tracks previously billed amounts for discounts', :aggregate_failures do
            context = result.data[:context]

            # Project items total: 5200€ (50×100 + 2×100)
            # Discounts total: 2300€ (1300 + 1000)
            # Project total after discounts (net): 2900€ (5200 - 2300)
            expect(context[:project_total_amount]).to eq(2900.0) # 5200 - 2300
            expect(context[:project_total_amount_before_discounts]).to eq(5200.0)

            expect(context[:project_version_discounts].length).to eq(2)

            # Previous invoice bills 2500 € of items which represents 48.08% of the order (2500 / 5200)
            # So 48.08% of each discount should have been previously billed
            # First discount: -1300 × (2500/5200) = -625
            # Second discount: -1000 × (2500/5200) = -480.77
            first_discount_previously_billed_amount = context.dig(:project_version_discounts, 0, :previously_billed_amount)
            expect(first_discount_previously_billed_amount).to be_within(0.01).of(-625)
            second_discount_previously_billed_amount = context.dig(:project_version_discounts, 1, :previously_billed_amount)
            expect(second_discount_previously_billed_amount).to be_within(0.01).of(-480.77)

            # project_total_previously_billed_amount should equal:
            # items billed (2500) - discounts deducted (625 + 480.77 = 1105.77) = 1394.23
            items_billed = previous_invoice_first_item_amount
            discounts_deducted = first_discount_previously_billed_amount.abs + second_discount_previously_billed_amount.abs
            expected_total = items_billed - discounts_deducted
            expect(context[:project_total_previously_billed_amount]).to be_within(0.01).of(expected_total)
          end
        end

        context 'when issue_date filters out future invoices' do
          let(:issue_date) { 3.days.ago }

          it 'does not include invoices after the issue date in previously billed amount', :aggregate_failures do
            context = result.data[:context]

            # The invoice created in the original before block was 2 days ago,
            # which is AFTER our issue_date of 3 days ago, so it should not be counted
            expect(context[:project_total_previously_billed_amount]).to eq(0.0)

            expect(context[:project_version_items].first).to include(
              original_item_uuid: 'item-uuid-1',
              previously_billed_amount: 0.0
            )
          end
        end

        context 'when required data is missing' do
          let(:invalid_project_version) { { number: 'PV-001' } }

          it 'returns failure with error message', :aggregate_failures do
            result = described_class.call(args.merge({ project_version: invalid_project_version }))
            expect(result).not_to be_success
          end
        end
        # rubocop:enable RSpec/ExampleLength
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
