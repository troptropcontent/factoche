require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
RSpec.describe Accounting::Proformas::Post do
  describe '.call' do
    include_context 'a company with a project with three items'

    let(:issue_date) { Time.current }
    let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }

    let(:original_proforma) {
      Organization::Proformas::Create.call(project_version.id, {
        issue_date: (Time.current - 15.days).to_date,
        invoice_amounts: [
          { original_item_uuid: first_item.original_item_uuid, invoice_amount: 1 },
          { original_item_uuid: second_item.original_item_uuid, invoice_amount: 2 }
        ]
      }).data
    }
    let(:proforma_id) { original_proforma.id }

    context 'when successful' do
      before do
        allow(Accounting::FinancialTransactions::FindNextAvailableNumber).to receive(:call)
          .with(company_id: original_proforma.company_id, prefix: "INV", financial_year_id: financial_year.id,  issue_date: issue_date)
          .and_return(ServiceResult.success("INV-2024-01-00001"))

        allow(Accounting::FinancialTransactions::GenerateAndAttachPdfJob).to receive(:perform_async)
      end

      it 'returns success with posted invoice', :aggregate_failures do
        result = described_class.call(proforma_id, issue_date)

        expect(result).to be_success
        expect(result.data).to be_a(Accounting::Invoice)
        expect(result.data.status).to eq("posted")
      end

      it 'posts the original invoice' do
        described_class.call(proforma_id, issue_date)

        expect(original_proforma.reload.status).to eq("posted")
      end

      it 'creates new invoice with correct attributes', :aggregate_failures do
        result = described_class.call(proforma_id, issue_date)
        posted_invoice = result.data

        expect(posted_invoice.number).to eq("INV-2024-01-00001")
        expect(posted_invoice.status).to eq("posted")
        expect(posted_invoice.issue_date).to be_within(1.second).of(issue_date)
        expect(posted_invoice.company_id).to eq(original_proforma.company_id)
        expect(posted_invoice.holder_id).to eq(original_proforma.holder_id)
      end

      it 'duplicates all invoice lines', :aggregate_failures do
        result = described_class.call(proforma_id, issue_date)
        posted_invoice = result.data

        expect(posted_invoice.lines.count).to eq(original_proforma.lines.count)

        original_proforma.lines.each_with_index do |original_line, index|
          posted_line = posted_invoice.lines[index]
          expect(posted_line.quantity).to eq(original_line.quantity)
          expect(posted_line.unit_price_amount).to eq(original_line.unit_price_amount)
          # Add other line attributes to compare
        end
      end

      it 'duplicates invoice details with an updated due_date and delivery_date', :aggregate_failures do
        result = described_class.call(proforma_id, issue_date)
        posted_invoice = result.data
        updated_attributes = [ 'id', 'financial_transaction_id', 'invoice_id', 'created_at', 'updated_at', 'due_date', 'delivery_date' ]

        expect(posted_invoice.detail).to be_present
        expect(posted_invoice.detail.attributes.except(*updated_attributes))
          .to eq(original_proforma.detail.attributes.except(*updated_attributes))

        expect(posted_invoice.detail.due_date).to be_within(1).of(Time.current + 30.days)
        expect(posted_invoice.detail.delivery_date).to be_within(1).of(issue_date)
      end

      it 'enqueues PDF generation job' do
        result = described_class.call(proforma_id, issue_date)

        expect(Accounting::FinancialTransactions::GenerateAndAttachPdfJob)
          .to have_received(:perform_async)
          .with({ "financial_transaction_id" => result.data.id })
      end
    end

    context 'when invoice is not in draft status' do
      before do
        original_proforma.update!(status: :posted)
      end

      it 'returns failure', :aggregate_failures do
        result = described_class.call(proforma_id, issue_date)

        expect(result).to be_failure
        expect(result.error.message).to include("Cannot post proforma that is not in draft status")
      end
    end

    context 'when something goes wrong' do
      before do
        allow(Accounting::FinancialTransactions::FindNextAvailableNumber).to receive(:call)
          .with(hash_including(
            company_id: original_proforma.company_id,
            prefix: "INV",
            issue_date: be_within(1.second).of(issue_date)
          ))
          .and_return(ServiceResult.failure("Database error"))
      end

      it 'returns failure', :aggregate_failures do
        result = described_class.call(proforma_id, issue_date)

        expect(result).to be_failure
        expect(result.error.message).to include("Database error")
      end
    end

    context 'when invoice is not found' do
      let(:proforma_id) { -1 }

      it 'returns failure', :aggregate_failures do
        result = described_class.call(proforma_id, issue_date)

        expect(result).to be_failure
        expect(result.error.message).to include("Couldn't find Accounting::Proforma with 'id'=-1")
      end
    end
  end
end
