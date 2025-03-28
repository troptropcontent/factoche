require 'rails_helper'

require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"
# rubocop:disable RSpec/MultipleMemoizedHelpers
RSpec.describe Organization::Invoices::Create do
  include_context 'a company with a project with three item groups'

  describe '.call' do
    subject(:result) {
      described_class.call(project_version.id, params)
    }

    let(:project_version_first_item_group_item_unit_price_amount) { 123 }
    let(:project_version_first_item_group_item_unit_quantity) { 2 }
    let(:project_version_first_item_group_item_tax_rate) { 0.10 }

    let(:project_version_second_item_group_item_unit_price_amount) { 232 }
    let(:project_version_second_item_group_item_unit_quantity) { 40 }
    let(:project_version_second_item_group_item_tax_rate) { 0.20 }

    let(:project_version_retention_guarantee_rate) { 0.04 }

    let(:params) do
      {
        invoice_amounts: [
          {
            original_item_uuid: first_item.original_item_uuid,
            invoice_amount: 20
          }, {
            original_item_uuid: second_item.original_item_uuid,
            invoice_amount: 123
          }
        ]
      }
    end

    context 'when all validations pass' do
      it {
        expect(result).to be_success
      }

      it 'creates a completion snapshot invoice, its detail record and its lines records successfully', :aggregate_failures do
        expect { result }
          .to change(Accounting::Invoice, :count).by(1)
          .and change(Accounting::FinancialTransactionDetail, :count).by(1)
          .and change(Accounting::FinancialTransactionLine, :count).by(2)

          # Calculate the expected total excluding tax amount
          # For the first item: 20 (invoice_amount) = 20
          # For the second item: 123 (invoice_amount) = 123
          # Total excluding tax amount = 20 + 123 = 143
          expect(result.data.total_excl_tax_amount).to eq(143)

          # Calculate the expected total including tax amount
          # first item has a tax rate of 0.10 (10%), second item has a tax rate of 0.20 (20%)
          # Total including tax for first item = 20 + (20 * 0.10) = 22
          # Total including tax for second item = 123 + (123 * 0.20) = 147.6
          # Total including tax amount = 22 + 147.6 = 169.6
          expect(result.data.total_including_tax_amount).to eq(169.6)

          # Calculate the expected total excluding retention guarantee amount
          # Retention guarantee rate is 0.04 (4%)
          # Total excluding retention guarantee = Total including tax amount * (1 - retention guarantee rate)
          # = 169.6 * (1 - 0.04) = 162.82
          expect(result.data.total_excl_retention_guarantee_amount).to eq(162.82)
      end
    end

    context 'when validations fail' do
      context 'when project version is not the last one' do
        before do
          FactoryBot.create(:project_version, project: project, retention_guarantee_rate: project_version_retention_guarantee_rate)
        end

        it { is_expected.to be_failure }

        it 'raises an error', :aggregate_failures do
          expect(result.error).to include("Can only create completion snapshot invoice from the last version")
        end
      end

      context 'when there is already a draft for this project' do
        before do
          described_class.call(project_version.id, params)
        end

        it { is_expected.to be_failure }

        it 'raises an error', :aggregate_failures do
          expect(result.error).to include("Cannot create a new invoice while another draft invoice exists for this project")
        end
      end

      context 'when invoice amount references non-existent item' do
        let(:params) do
          {
            invoice_amounts: [
              {
                original_item_uuid: 'non-existent-uuid',
                invoice_amount: 100.0
              }
            ]
          }
        end

        it { is_expected.to be_failure }

        it 'raises an error', :aggregate_failures do
          expect(result.error).to include("All invoice amounts must reference items that exist in the project version")
        end
      end

      context 'when invoice amount exceeds item total amount' do
        before do
        # Create a previous invoice for this item
        invoice = described_class.call(
            project_version.id,
            {
              invoice_amounts: [
                {
                  original_item_uuid: first_item.original_item_uuid,
                  invoice_amount: first_item.quantity * first_item.unit_price_amount # previous invoice for this item with total amount
                }
              ]
            }
          ).data

          invoice.update!(status: :posted, number: "INV-2024-00001")
        end

        it { is_expected.to be_failure }

        it 'raises an error when trying to invoice more than remaining amount' do
          expect(result.error).to include("Invoice amount would exceed item total amount")
        end
      end
    end
  end
end
# rubocop:enable RSpec/MultipleMemoizedHelpers
