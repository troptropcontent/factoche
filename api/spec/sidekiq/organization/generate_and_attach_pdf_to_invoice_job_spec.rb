require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"

RSpec.describe Organization::GenerateAndAttachPdfToInvoiceJob do
  describe '#perform' do
    include_context 'a company with a project with three item groups'
    let(:completion_snapshot) do
      FactoryBot.create(
        :completion_snapshot,
        project_version: project_version,
        completion_snapshot_items_attributes: [],
      )
    end
    let(:invoice) { FactoryBot.create(:invoice, completion_snapshot: completion_snapshot) }

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
        described_class.new.perform("completion_snapshot_id" => completion_snapshot.id)
      }.to change { invoice.reload.pdf.attached? }.from(false).to(true)
    end

    it 'calls the PDF generator with the correct URL' do
      described_class.new.perform("completion_snapshot_id" => completion_snapshot.id)

      expected_url = Rails.application.routes.url_helpers.api_v1_organization_invoice_url(
        completion_snapshot,
        host: "html_pdf:8081"
      )

      expect(HeadlessBrowserPdfGenerator).to have_received(:call).with(expected_url)
    end

    context 'when invoice is missing' do
      before do
        invoice.destroy
      end

      it 'raises an UnprocessableEntityError' do
        expect {
          described_class.new.perform("completion_snapshot_id" => completion_snapshot.id)
        }.to raise_error(Error::UnprocessableEntityError, /No invoice exists/)
      end
    end

    context 'when headless browser config is missing' do
      before do
        allow(Rails.configuration).to receive(:headless_browser).and_return(nil)
      end

      it 'raises an UnprocessableEntityError' do
        expect {
          described_class.new.perform("completion_snapshot_id" => completion_snapshot.id)
        }.to raise_error(Error::UnprocessableEntityError, /configuration is missing/)
      end
    end
  end
end
