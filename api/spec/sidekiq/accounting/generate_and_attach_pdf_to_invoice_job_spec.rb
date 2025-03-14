require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"

RSpec.describe Accounting::GenerateAndAttachPdfToInvoiceJob do
  describe '#perform' do
    include_context 'a company with a project with three items'

    let(:invoice) { ::Organization::Invoices::Create.call(project_version.id, { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" } ] }).data }

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

    it 'generates and attaches PDF to the invoice' do
      expect {
        described_class.new.perform("invoice_id" => invoice.id)
      }.to change { invoice.reload.pdf.attached? }.from(false).to(true)
    end

    context "when the invoice is published" do
      before { invoice.update(status: :posted, number: "INV-2024-00001") }

      it 'calls the PDF generator with the correct URL' do
        described_class.new.perform("invoice_id" => invoice.id)

        expected_url = Rails.application.routes.url_helpers.accounting_prints_published_invoice_url(
          invoice,
          host: "html_pdf:8081"
        )

        expect(HeadlessBrowserPdfGenerator).to have_received(:call).with(expected_url)
      end
    end

    context "when the invoice is unpublished" do
      it 'calls the PDF generator with the correct URL' do
        described_class.new.perform("invoice_id" => invoice.id)

        expected_url = Rails.application.routes.url_helpers.accounting_prints_unpublished_invoice_url(
          invoice,
          host: "html_pdf:8081"
        )

        expect(HeadlessBrowserPdfGenerator).to have_received(:call).with(expected_url)
      end
    end

    context "when the invoice has already a pdf attached" do
      before {
        pdf_attachment = instance_double(ActiveStorage::Attached::One, attached?: true)
        invoice_double = instance_double(Accounting::Invoice, pdf: pdf_attachment)
        allow(Accounting::Invoice).to receive(:find).and_return(invoice_double)
      }

      it 'calls the PDF generator with the correct URL' do
        described_class.new.perform("invoice_id" => invoice.id)

        expect(HeadlessBrowserPdfGenerator).not_to have_received(:call)
      end
    end

    context 'when invoice is missing' do
      it 'raises an UnprocessableEntityError' do
        expect {
          described_class.new.perform("invoice_id" => "an-id-that-do-not-exists")
        }.to raise_error(ActiveRecord::RecordNotFound, "Couldn't find Accounting::Invoice with 'id'=an-id-that-do-not-exists")
      end
    end

    context 'when headless browser config is missing' do
      before do
        allow(Rails.configuration).to receive(:headless_browser).and_return(nil)
      end

      it 'raises an UnprocessableEntityError' do
        expect {
          described_class.new.perform("invoice_id" => invoice.id)
        }.to raise_error(Error::UnprocessableEntityError, /configuration is missing/)
      end
    end
  end
end
