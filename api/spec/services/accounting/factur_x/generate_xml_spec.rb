require "rails_helper"
require "support/shared_contexts/organization/projects/a_company_with_some_orders"

RSpec.describe Accounting::FacturX::GenerateXml do
  describe "#call" do
    subject(:result) { described_class.call(invoice.id, configs) }

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

    let(:configs) { {} }


    after { result.data.close! } # Cleanup Tempfile

    it "returns valid XML" do
      expect { Nokogiri::XML(result.data.read) }.not_to raise_error
    end

    it "includes invoice number in the XML" do
      expect(result.data.read).to include("<ram:ID>#{invoice.number}</ram:ID>")
    end

    it "includes currency code" do
      expect(result.data.read).to include("<ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>")
    end

    it "includes line items" do
      content = result.data.read
      invoice.lines.each do |line|
        expect(content).to include(line.excl_tax_amount.to_s)
      end
    end

    it "includes seller and buyer names", :aggregate_failures do
      content = result.data.read
      expect(content).to include("<ram:Name>#{invoice.detail.seller_name}</ram:Name>")
      expect(content).to include("<ram:Name>#{invoice.detail.client_name}</ram:Name>")
    end

    it "matches expected XML structure (sanity check root tag)" do
      doc = Nokogiri::XML(result.data.read)
      expect(doc.root.name).to eq("CrossIndustryInvoice")
    end
  end
end
