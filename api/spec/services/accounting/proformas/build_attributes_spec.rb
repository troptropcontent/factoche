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

        before do
          # Create a previously posted invoice for the item
          creation_service_result = Create.call(
            company:,
            client:,
            project:,
            project_version:,
            new_invoice_items: [ {
              original_item_uuid: 'item-uuid-1',
              invoice_amount: 50
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
            # Project total: 200€ (2 items × 100€)
            # Discounts total: 40€ (2 × 20€)
            # Invoice amount before discount: 150€
            # Invoice proportion: 150/200 = 0.75
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
