require 'rails_helper'

module Accounting
  module FinancialTransactions
    RSpec.describe PostCompletionSnapshotInvoice do
      describe '.call' do
        subject(:result) { described_class.call(invoice_id, issue_date) }

        let(:invoice_id) { invoice.id }
        let(:issue_date) { Date.new(2024, 1, 9) }
        let!(:invoice) { FactoryBot.create(:completion_snapshot_invoice, company_id: 2, holder_id: 'something') }

        context 'when invoice is in draft status' do
          it "returns a success" do
            expect(result).to be_success
          end

          it 'updates the invoice status to posted' do
            expect { result }.to change { invoice.reload.status }.from('draft').to('posted')
          end

          it 'assigns a number' do
            expect { result }.to change { invoice.reload.number }.from(nil).to("INV-2024-000001")
          end
        end

        context 'when invoice is not in draft status' do
          before {
            invoice.update!(status: :posted, number: "INV-TOTO")
          }

          it "returns a failure" do
            expect(result).to be_failure
          end

          it 'returns a failure result' do
            expect(result.error).to include('Cannot post invoice that is not in draft status')
          end

          it 'does not change the invoice status' do
            expect { result }.not_to change { invoice.reload.status }
          end

          it 'does not assign a number' do
            expect { result }.not_to change { invoice.reload.number }
          end
        end

        context 'when invoice is not found' do
          let(:invoice_id) { 99999999 }

          it "returns a failure" do
            expect(result).to be_failure
          end

          it 'returns a failure result' do
            expect(result.error).to include("Failed to post invoice: Couldn't find Accounting::CompletionSnapshotInvoice with 'id'=99999999")
          end
        end
      end
    end
  end
end
