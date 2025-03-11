require 'rails_helper'

module Accounting
  module FinancialTransactions
    RSpec.describe FindNextAvailableInvoiceNumber do
      describe '.call' do
        subject(:result) { described_class.call(company_id, issue_date) }

        let(:company_id) { 1 }
        let(:issue_date) { Date.new(2024, 1, 9) }

        context 'when there are no existing invoices' do
          it { is_expected.to be_success }

          it 'returns INV-2024-000001 as the first invoice number' do
            expect(result.data).to eq("INV-2024-000001")
          end
        end

        context 'when there are existing invoices' do
          before do
            FactoryBot.create_list(:completion_snapshot_invoice, 3, company_id: company_id, holder_id: "something", status: :posted)
          end

          it { is_expected.to be_success }

          it 'returns the next available number' do
            expect(result.data).to eq("INV-2024-000004")
          end
        end

        context 'when there are invoices from different companies' do
          let(:other_company_id) { 2 }

          before do
            FactoryBot.create_list(:completion_snapshot_invoice, 3, company_id: other_company_id, holder_id: "something", status: :posted)
          end

          it { is_expected.to be_success }

          it 'only counts invoices for the specified company' do
            expect(result.data).to eq("INV-2024-000001")
          end
        end

        context 'when an error occurs' do
          before do
            allow(FinancialTransaction).to receive(:where)
              .and_raise(StandardError.new('Database connection error'))
          end

          it { is_expected.to be_failure }

          it 'returns a failure result with error message' do
            expect(result.error).to eq('Failed to find next available invoice number: Database connection error')
          end
        end
      end
    end
  end
end
