require 'rails_helper'

require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"

RSpec.describe Organization::Invoices::CompletionSnapshots::Create do
  include_context 'a company with a project with three item groups'
  describe '.call' do
    subject(:result) { described_class.call(project_version.id, params) }

    let(:params) do
     { invoice_amounts:  [ {
      original_item_uuid: first_item.original_item_uuid,
      invoice_amount: first_item.quantity % 3 *  first_item.unit_price_cents / 100
    } ] }
    end

    context 'when all validations pass' do
      it { is_expected.to be_success }

      it 'creates a completion snapshot invoice, its detail record and its lines records successfully', :aggregate_failures do
        expect { result }
          .to change(Accounting::CompletionSnapshotInvoice, :count).by(1)
          .and change(Accounting::FinancialTransactionDetail, :count).by(1)
          .and change(Accounting::FinancialTransactionLine, :count).by(3)
      end
    end

    context 'when validations fail' do
      context 'when project version is not the last one' do
        before {
          FactoryBot.create(:project_version, project: project, retention_guarantee_rate: project_version_retention_guarantee_rate)
        }

        it { is_expected.to be_failure }

        it 'raises an error', :aggregate_failures do
          expect(result.error).to include("Can only create completion snapshot invoice from the last version")
        end
      end

      context 'when invoice amount references non-existent item' do
        let(:params) do
          { invoice_amounts: [ {
            original_item_uuid: 'non-existent-uuid',
            invoice_amount: 100.0
          } ] }
        end

        it { is_expected.to be_failure }

        it 'raises an error', :aggregate_failures do
          expect(result.error).to include("All invoice amounts must reference items that exist in the project version")
        end
      end

      context 'when invoice amount exceeds item total amount' do
        before do
          # Create a previous invoice for this item
          described_class.call(
            project_version.id,
            {
              invoice_amounts: [
                {
                  original_item_uuid: first_item.original_item_uuid,
                  invoice_amount: first_item.quantity * first_item.unit_price_cents / 100 # previous invoice for this item with total amount
                }
              ]
            }
          )
        end

        it { is_expected.to be_failure }

        it 'raises an error when trying to invoice more than remaining amount' do
          expect(result.error).to include("Invoice amount would exceed item total amount")
        end
      end
    end
  end
end
