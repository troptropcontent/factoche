require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

RSpec.describe Accounting::Invoices::Cancel do
  describe '.call', :aggregate_failures do
    include_context 'a company with an order'

    let(:issue_date) { Time.current }
    let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
    let(:original_invoice) {
      proforma = ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data
      Accounting::Proformas::Post.call(proforma.id).data
    }
    let(:invoice_id) { original_invoice.id }

    before do
      allow(Accounting::FinancialTransactions::FindNextAvailableNumber).to receive(:call)
        .with(hash_including(
          company_id: original_invoice.company_id,
          prefix: Accounting::CreditNote::NUMBER_PREFIX,
          issue_date: issue_date
        ))
        .and_return(ServiceResult.success("CN-2024-01-000001"))

      allow(Accounting::FinancialTransactions::GenerateAndAttachPdfJob).to receive(:perform_async)
    end

    context 'when successful' do
      it 'returns success with cancelled invoice and credit note' do
        result = described_class.call(invoice_id, issue_date)

        expect(result).to be_success
        expect(result.data[:invoice]).to eq(original_invoice)
        expect(result.data[:credit_note]).to be_a(Accounting::CreditNote)
      end

      it 'cancels the original invoice' do
        expect {
          described_class.call(invoice_id, issue_date)
        }.to change { original_invoice.reload.status }.to("cancelled")
      end

      it 'creates a posted credit note', :aggregate_failures do
        result = described_class.call(invoice_id, issue_date)
        credit_note = result.data[:credit_note]

        expect(credit_note.number).to eq("CN-2024-01-000001")
        expect(credit_note.status).to eq("posted")
        expect(credit_note.issue_date).to be_within(1.second).of(issue_date)
        expect(credit_note.company_id).to eq(original_invoice.company_id)
        expect(credit_note.holder_id).to eq(original_invoice.id)
      end

      it 'copies all invoice lines', :aggregate_failures do
        result = described_class.call(invoice_id, issue_date)
        credit_note = result.data[:credit_note]

        expect(credit_note.lines.count).to eq(original_invoice.lines.count)

        original_invoice.lines.each_with_index do |original_line, index|
          credit_note_line = credit_note.lines[index]
          expect(credit_note_line.quantity).to eq(original_line.quantity)
          expect(credit_note_line.unit_price_amount).to eq(original_line.unit_price_amount)
        end
      end

      it 'copies invoice details', :aggregate_failures do
        result = described_class.call(invoice_id, issue_date)
        credit_note = result.data[:credit_note]

        expect(credit_note.detail).to be_present

        expect(credit_note.detail.attributes.except('id', 'financial_transaction_id', 'created_at', 'updated_at'))
          .to eq(original_invoice.detail.attributes.except('id', 'financial_transaction_id', 'created_at', 'updated_at'))
      end

      it 'enqueues PDF generation job' do
        result = described_class.call(invoice_id, issue_date)

        expect(Accounting::FinancialTransactions::GenerateAndAttachPdfJob)
          .to have_received(:perform_async)
          .with({ "financial_transaction_id" => result.data[:credit_note].id })
      end
    end

    context 'with invalid parameters' do
      context 'when invoice_id is blank' do
        let(:invoice_id) { nil }

        it 'returns failure' do
          result = described_class.call(invoice_id, issue_date)

          expect(result).to be_failure
          expect(result.error).to include("Invoice ID is required")
        end
      end

      context 'when issue_date is blank' do
        let(:issue_date) { nil }

        it 'returns failure' do
          result = described_class.call(invoice_id, issue_date)

          expect(result).to be_failure
          expect(result.error).to include("Issue date is required")
        end
      end
    end

    context 'when invoice is not found' do
      let(:invoice_id) { -1 }

      it 'returns failure' do
        result = described_class.call(invoice_id, issue_date)

        expect(result).to be_failure
        expect(result.error).to include("Couldn't find Accounting::Invoice")
      end
    end

    context 'when invoice is not in posted status' do
      before do
        original_invoice.update!(status: :cancelled)
      end

      it 'returns failure' do
        result = described_class.call(invoice_id, issue_date)

        expect(result).to be_failure
        expect(result.error).to include("Cannot cancel invoice that is not in posted status")
      end
    end

    context 'when credit note number generation fails' do
      before do
        allow(Accounting::FinancialTransactions::FindNextAvailableNumber).to receive(:call)
          .and_return(ServiceResult.failure("Number generation failed"))
      end

      it 'returns failure' do
        result = described_class.call(invoice_id, issue_date)

        expect(result).to be_failure
        expect(result.error).to include("Number generation failed")
      end
    end
  end
end
