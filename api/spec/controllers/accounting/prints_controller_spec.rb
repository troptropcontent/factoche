require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"

RSpec.describe "Accounting::Prints", type: :request do
  describe "GET /accounting/prints/unpublished_invoice/:id" do
    include_context 'a company with a project with three items'

    let(:invoice) do
      Organization::Invoices::Create.call(project_version.id, {
        invoice_amounts: [
          { original_item_uuid: first_item.original_item_uuid, invoice_amount: 1 },
          { original_item_uuid: second_item.original_item_uuid, invoice_amount: 2 }
        ]
      }).data
    end
    let(:id) { invoice.id }

    context "when microservice env is set" do
      before do
        allow(ENV).to receive(:fetch).and_call_original
        allow(ENV).to receive(:fetch).with("RAILS_PRINT_MICROSERVICE", nil).and_return("true")
      end

      context "when invoice exists" do
        context "with draft status" do
          it "renders the invoice print html", :aggregate_failures do
            get "/accounting/prints/unpublished_invoices/#{id}"

            expect(response.content_type).to include("text/html")
            expect(response.code).to eq("200")
            expect(response.body).to include("Facture proforma")
            expect(response.body).to include(invoice.number)
          end
        end

        context "with voided status" do
          before { invoice.update!(status: :voided) }

          it "renders the invoice print html", :aggregate_failures do
            get "/accounting/prints/unpublished_invoices/#{id}"

            expect(response.content_type).to include("text/html")
            expect(response.code).to eq("200")
            expect(response.body).to include("Facture proforma")
            expect(response.body).to include(invoice.number)
          end
        end

        context "with posted status" do
          before { invoice.update!(status: :posted, number: "INV-2024-00001") }

          it "returns a 422", :aggregate_failures do
            get "/accounting/prints/unpublished_invoices/#{id}"

            expect(response.content_type).to include("text/html")
            expect(response.code).to eq("422")
            expect(response.body).to include("Invoice must be unpublished")
          end
        end
      end

      context "when invoice does not exist" do
        let(:id) { "id-that-dont-exists" }

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
end
