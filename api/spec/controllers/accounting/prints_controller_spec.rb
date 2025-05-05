require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
require 'support/shared_contexts/organization/projects/a_company_with_an_order'
RSpec.describe "Accounting::Prints", type: :request do
  describe "GET /accounting/prints/unpublished_invoice/:id" do
    include_context 'a company with an order'

    let(:proforma) do
      Organization::Proformas::Create.call(order_version.id, {
        invoice_amounts: [
          { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 1 },
          { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 2 }
        ]
      }).data
    end

    let(:id) { proforma.id }

    context "when microservice env is set" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("RAILS_PRINT_MICROSERVICE", nil).and_return("true")
      end

      context "when proforma exists" do
        it "renders the invoice print html", :aggregate_failures do
          get "/accounting/prints/unpublished_invoices/#{id}"

          expect(response.content_type).to include("text/html")
          expect(response.code).to eq("200")
          expect(response.body).to include("Facture proforma")
          expect(response.body).to include(proforma.number)
        end
      end

      context "when proforma does not exist" do
        let(:id) { -1 }

        it "returns a 422", :aggregate_failures do
          get "/accounting/prints/unpublished_invoices/#{id}"

          expect(response.content_type).to include("text/html")
          expect(response.code).to eq("422")
          expect(response.body).to include("No invoice found for this id")
        end
      end
    end

    context "when microservice env is not set" do
      it "returns a 422", :aggregate_failures do
        get "/accounting/prints/unpublished_invoices/#{id}"

        expect(response.content_type).to include("text/html")
        expect(response.code).to eq("422")
        expect(response.body).to include("This endpoint is only available in the print microservice")
      end
    end
  end

  describe "GET /accounting/prints/published_invoice/:id" do
    include_context 'a company with an order'

    let(:proforma) do
      Organization::Proformas::Create.call(order_version.id, {
        invoice_amounts: [
          { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 1 },
          { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 2 }
        ]
      }).data
    end

    let(:invoice) { Accounting::Proformas::Post.call(proforma.id).data }

    let(:id) { invoice.id }

    context "when microservice env is set" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("RAILS_PRINT_MICROSERVICE", nil).and_return("true")
      end

      context "when invoice exists" do
        it "renders the invoice print html", :aggregate_failures do
          get "/accounting/prints/published_invoices/#{id}"

          expect(response.content_type).to include("text/html")
          expect(response.code).to eq("200")
          expect(response.body).to include("Facture")
          expect(response.body).to include(invoice.number)
        end
      end

      context "when proforma does not exist" do
        let(:id) { -1 }

        it "returns a 422", :aggregate_failures do
          get "/accounting/prints/published_invoices/#{id}"

          expect(response.content_type).to include("text/html")
          expect(response.code).to eq("422")
          expect(response.body).to include("No invoice found for this id")
        end
      end
    end

    context "when microservice env is not set" do
      it "returns a 422", :aggregate_failures do
        get "/accounting/prints/published_invoices/#{id}"

        expect(response.content_type).to include("text/html")
        expect(response.code).to eq("422")
        expect(response.body).to include("This endpoint is only available in the print microservice")
      end
    end
  end

  describe "GET /accounting/prints/credit_notes/:id" do
    include_context 'a company with an order'

    let(:proforma) do
      Organization::Proformas::Create.call(order_version.id, {
        invoice_amounts: [
          { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 1 },
          { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 2 }
        ]
      }).data
    end

    let(:invoice) { Accounting::Proformas::Post.call(proforma.id).data }

    let(:credit_note) { Accounting::Invoices::Cancel.call(invoice.id).data[:credit_note] }

    let(:id) { credit_note.id }

    context "when microservice env is set" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("RAILS_PRINT_MICROSERVICE", nil).and_return("true")
      end

      context "when invoice exists" do
        it "renders the invoice print html", :aggregate_failures do
          get "/accounting/prints/credit_notes/#{id}"

          expect(response.content_type).to include("text/html")
          expect(response.code).to eq("200")
          expect(response.body).to include("Avoir")
          expect(response.body).to include(credit_note.number)
        end
      end

      context "when proforma does not exist" do
        let(:id) { -1 }

        it "returns a 422", :aggregate_failures do
          get "/accounting/prints/credit_notes/#{id}"

          expect(response.content_type).to include("text/html")
          expect(response.code).to eq("422")
          expect(response.body).to include("No credit_note found for this id")
        end
      end
    end

    context "when microservice env is not set" do
      it "returns a 422", :aggregate_failures do
        get "/accounting/prints/credit_notes/#{id}"

        expect(response.content_type).to include("text/html")
        expect(response.code).to eq("422")
        expect(response.body).to include("This endpoint is only available in the print microservice")
      end
    end
  end
end
