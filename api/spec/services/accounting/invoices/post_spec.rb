require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
RSpec.describe Accounting::Invoices::Post do
  describe '.call' do
    include_context 'a company with a project with three items'

    let(:issue_date) { Time.current }
    let(:original_invoice) {
      Organization::Invoices::Create.call(project_version.id, {
        invoice_amounts: [
          { original_item_uuid: first_item.original_item_uuid, invoice_amount: 1 },
          { original_item_uuid: second_item.original_item_uuid, invoice_amount: 2 }
        ]
      }).data
    }
    let(:invoice_id) { original_invoice.id }

    context 'when successful' do
      before do
        allow(Accounting::Invoices::FindNextAvailableNumber).to receive(:call)
          .with(company_id: original_invoice.company_id, published: true, issue_date: issue_date)
          .and_return(ServiceResult.success("INV-2024-00001"))

        allow(Accounting::GenerateAndAttachPdfToInvoiceJob).to receive(:perform_async)
      end

      it 'returns success with posted invoice', :aggregate_failures do
        result = described_class.call(invoice_id, issue_date)

        expect(result).to be_success
        expect(result.data).to be_a(Accounting::Invoice)
        expect(result.data.status).to eq("posted")
      end

      it 'voids the original invoice' do
        described_class.call(invoice_id, issue_date)

        expect(original_invoice.reload.status).to eq("voided")
      end

      it 'creates new invoice with correct attributes', :aggregate_failures do
        result = described_class.call(invoice_id, issue_date)
        posted_invoice = result.data

        expect(posted_invoice.number).to eq("INV-2024-00001")
        expect(posted_invoice.status).to eq("posted")
        expect(posted_invoice.issue_date).to be_within(1.second).of(issue_date)
        expect(posted_invoice.company_id).to eq(original_invoice.company_id)
        expect(posted_invoice.holder_id).to eq(original_invoice.holder_id)
      end

      it 'duplicates all invoice lines', :aggregate_failures do
        result = described_class.call(invoice_id, issue_date)
        posted_invoice = result.data

        expect(posted_invoice.lines.count).to eq(original_invoice.lines.count)

        original_invoice.lines.each_with_index do |original_line, index|
          posted_line = posted_invoice.lines[index]
          expect(posted_line.quantity).to eq(original_line.quantity)
          expect(posted_line.unit_price_amount).to eq(original_line.unit_price_amount)
          # Add other line attributes to compare
        end
      end

      it 'duplicates invoice details', :aggregate_failures do
        result = described_class.call(invoice_id, issue_date)
        posted_invoice = result.data

        expect(posted_invoice.detail).to be_present
        expect(posted_invoice.detail.attributes.except('id', 'financial_transaction_id', 'invoice_id', 'created_at', 'updated_at'))
          .to eq(original_invoice.detail.attributes.except('id', 'financial_transaction_id', 'invoice_id', 'created_at', 'updated_at'))
      end

      it 'enqueues PDF generation job' do
        result = described_class.call(invoice_id, issue_date)

        expect(Accounting::GenerateAndAttachPdfToInvoiceJob)
          .to have_received(:perform_async)
          .with({ "invoice_id" => result.data.id })
      end
    end

    context 'when invoice is not in draft status' do
      before do
        original_invoice.update!(status: :posted, number: "INV-2024-000001")
      end

      it 'returns failure', :aggregate_failures do
        result = described_class.call(invoice_id, issue_date)

        expect(result).to be_failure
        expect(result.error).to include("Cannot post invoice that is not in draft status")
      end
    end

    context 'when something goes wrong' do
      before do
        allow(Accounting::Invoices::FindNextAvailableNumber).to receive(:call)
          .with(hash_including(
            company_id: original_invoice.company_id,
            published: true,
            issue_date: be_within(1.second).of(issue_date)
          ))
          .and_return(ServiceResult.failure("Database error"))
      end

      it 'returns failure', :aggregate_failures do
        result = described_class.call(invoice_id, issue_date)

        expect(result).to be_failure
        expect(result.error).to include("Database error")
      end
    end

    context 'when invoice is not found' do
      let(:invoice_id) { -1 }

      it 'returns failure', :aggregate_failures do
        result = described_class.call(invoice_id, issue_date)

        expect(result).to be_failure
        expect(result.error).to include("Couldn't find Accounting::Invoice")
      end
    end
  end
end
