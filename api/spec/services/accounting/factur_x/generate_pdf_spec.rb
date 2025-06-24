require 'rails_helper'
require "support/shared_contexts/organization/projects/a_company_with_some_orders"

RSpec.describe Accounting::FacturX::GeneratePdf, type: :service do
  include_context 'a company with some orders'

  let(:invoice) do
    proforma = Organization::Proformas::Create.call(first_order.last_version.id, {
      invoice_amounts: [
        { original_item_uuid: first_order.last_version.items.first.original_item_uuid, invoice_amount: 1 },
        { original_item_uuid: first_order.last_version.items.second.original_item_uuid, invoice_amount: 2 }
      ]
    }).data
    Accounting::Proformas::Post.call(proforma.id).data
  end

  let(:pdf_file) { Tempfile.new([ 'invoice', '.pdf' ]) }
  let(:xml_file) { Tempfile.new([ 'facturx', '.xml' ]) }
  let(:facturx_pdf_content) { '%PDF-1.4 This is a fake FacturX PDF content' }

  before do
    # Attach fake PDF
    invoice.pdf.attach(
      io: pdf_file,
      filename: 'invoice.pdf',
      content_type: 'application/pdf'
    )

    # Stub the internal XML generation call (returns the same xml_file)
    allow(Accounting::FacturX::GenerateXml).to receive(:call).and_return(
      OpenStruct.new(success?: true, data: xml_file)
    )

    # Stub external call to factur_x microservice
    stub_request(:post, "http://factur_x:5000/generate_facturx")
      .to_return(status: 200, body: facturx_pdf_content, headers: { 'Content-Type' => 'application/pdf' })
  end

  it 'generates a Factur-X PDF and returns a Tempfile', :aggregate_failures do
    result = described_class.call(invoice.id)

    expect(result.data).to be_a(Tempfile)
    expect(result.data.read).to eq(facturx_pdf_content)
    expect(WebMock).to have_requested(:post, "http://factur_x:5000/generate_facturx").once
  end

  context 'when the PDF is missing' do
    before { invoice.pdf.purge }

    it 'raises an error', :aggregate_failures do
      result = described_class.call(invoice.id)
      expect(result).to be_failure
      expect(result.error.message).to include('pdf file must have been generated')
    end
  end
end
