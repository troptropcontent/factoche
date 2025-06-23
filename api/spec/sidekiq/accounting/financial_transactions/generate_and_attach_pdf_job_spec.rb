require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

RSpec.describe Accounting::FinancialTransactions::GenerateAndAttachPdfJob do
  describe '#perform' do
    include_context 'a company with an order'
    include_context 'a company with a project with three items'


    let(:proforma) do
                  ::Organization::Proformas::Create.call(order_version.id, {
                    invoice_amounts: [
                      { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 1 },
                      { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 2 }
                    ]
                  }).data
    end

    let(:invoice) { ::Accounting::Proformas::Post.call(proforma.id).data }

    let(:pdf_file) { Tempfile.new([ 'test', '.pdf' ]) }

    before do
      allow(HeadlessBrowserPdfGenerator).to receive(:call)
        .and_return(pdf_file)
      invoice
    end

    after do
      pdf_file.close
      pdf_file.unlink
    end

    it 'generates and attaches PDF to the financial transaction' do
      expect {
        described_class.new.perform("financial_transaction_id" => invoice.id)
      }.to change { invoice.reload.pdf.attached? }.from(false).to(true)
    end

    context "when the financial transaction is an invoice" do
      it 'calls the PDF generator with the correct URL' do
        described_class.new.perform("financial_transaction_id" => invoice.id)

        expected_url = Rails.application.routes.url_helpers.accounting_prints_published_invoice_url(
          invoice,
          host: "html_pdf:8081"
        )

        expect(HeadlessBrowserPdfGenerator).to have_received(:call).with(%r{/accounting/prints/published_invoices/\d+\?token=.+$})
      end
    end

    context "when the financial transaction is an proforma" do
      it 'calls the PDF generator with the correct URL' do
        described_class.new.perform("financial_transaction_id" => proforma.id)

        expected_url = %r{^http://html_pdf:8081/accounting/prints/unpublished_invoices/\d+\?token=.+$}

        expect(HeadlessBrowserPdfGenerator).to have_received(:call).with(expected_url)
      end
    end

    context "when the financial transaction is a credit note" do
      let (:credit_note) { FactoryBot.create(:credit_note, :posted, company_id: company.id, client_id: client.id, holder_id: invoice.id, number: "CN-2024-00001") }

      it 'calls the PDF generator with the correct URL' do
        described_class.new.perform("financial_transaction_id" => credit_note.id)

        expected_url = %r{^http://html_pdf:8081/accounting/prints/credit_notes/\d+\?token=.+$}

        expect(HeadlessBrowserPdfGenerator).to have_received(:call).with(expected_url)
      end
    end

    context "when the financial transaction already has a PDF attached" do
      before {
        pdf_attachment = instance_double(ActiveStorage::Attached::One, attached?: true)
        invoice_double = instance_double(Accounting::FinancialTransaction, pdf: pdf_attachment)
        allow(Accounting::FinancialTransaction).to receive(:find).and_return(invoice_double)
      }

      it 'does not generate a new PDF' do
        described_class.new.perform("financial_transaction_id" => invoice.id)

        expect(HeadlessBrowserPdfGenerator).not_to have_received(:call)
      end
    end

    context 'when financial transaction is not found' do
      it 'raises a RecordNotFound error' do
        expect {
          described_class.new.perform("financial_transaction_id" => "an-id-that-do-not-exists")
        }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Accounting::FinancialTransaction with 'id'=an-id-that-do-not-exists")
      end
    end
  end
end
