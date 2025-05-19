require "rails_helper"
require 'support/shared_contexts/organization/projects/a_company_with_some_orders'
RSpec.describe Accounting::FacturX::GenerateXml do
  describe "#call" do
    subject(:result) { described_class.call(invoice.id, configs) }

    include_context 'a company with some orders'

    let(:invoice) {
      proforma= Organization::Proformas::Create.call(first_order.last_version.id, {
        invoice_amounts: [
          { original_item_uuid: first_order.last_version.items.first.original_item_uuid, invoice_amount: 1 },
          { original_item_uuid: first_order.last_version.items.second.original_item_uuid, invoice_amount: 2 }
        ]
      }).data
      Accounting::Proformas::Post.call(proforma.id).data
    }

    let(:configs) { {} }

    it "returns valid XML" do
      expect { Nokogiri::XML(result.data) }.not_to raise_error
    end

    it "includes invoice number in the XML" do
      expect(result.data).to include("<ram:ID>#{invoice.number}</ram:ID>")
    end

    it "includes currency code" do
      expect(result.data).to include("<ram:InvoiceCurrencyCode>EUR</ram:InvoiceCurrencyCode>")
    end

    it "includes line items" do
      invoice.lines.each do |line|
        expect(result.data).to include(line.excl_tax_amount.to_s)
      end
    end

    it "includes seller and buyer names", :aggregate_failures do
      expect(result.data).to include("<ram:Name>#{invoice.detail.seller_name}</ram:Name>")
      expect(result.data).to include("<ram:Name>#{invoice.detail.client_name}</ram:Name>")
    end

    it "saves the file to tmp/facturx" do
      file_path = Rails.root.join("tmp", "facturx", "facturx_invoice_#{invoice.number}.xml")
      File.delete(file_path) if File.exist?(file_path)
      described_class.call(invoice.id, configs)
      expect(File).to exist(file_path)
    end

    it "matches expected XML structure (sanity check root tag)" do
      doc = Nokogiri::XML(result.data)
      expect(doc.root.name).to eq("CrossIndustryInvoice")
    end
  end
end
