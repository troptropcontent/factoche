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

        let(:project_version) { FactoryBot.build(:accounting_project_version_hash, id: 123) }

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
            name: 'Group 1',
            description: 'Group Description'
          )
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
