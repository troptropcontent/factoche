require 'rails_helper'
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"

RSpec.describe "Accounting::Prints", type: :request do
  describe "GET /accounting/prints/unpublished_invoice/:id" do
    include_context 'a company with a project with three items'

    let(:invoice) {
      Organization::Invoices::Create.call(project_version.id, {
        invoice_amounts: [
          { original_item_uuid: first_item.original_item_uuid, invoice_amount: 1 },
          { original_item_uuid: second_item.original_item_uuid, invoice_amount: 2 }
        ]
      }).data
    }
    let(:id) { invoice.id }

    context "when microservice env is set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("RAILS_PRINT_MICROSERVICE").and_return("true")
      end

      context "when invoice exists" do
        context "with draft status" do
          let(:invoice) { create(:accounting_invoice, status: :draft) }

          it "renders the invoice template", :aggregate_failures do
            get "/accounting/prints/unpublished_invoice/#{id}"

            expect(response.content_type).to include("text/html")
            expect(response).to render_template("accounting/invoice")
            expect(response).to render_template(layout: "print")
            expect(assigns(:invoice)).to eq(invoice)
            expect(assigns(:proforma)).to be true
            expect(assigns(:locale)).to eq(:fr)
          end
        end

        context "with voided status" do
          let(:invoice) { create(:accounting_invoice, status: :voided) }

          it "renders the invoice template", :aggregate_failures do
            get "/accounting/prints/unpublished_invoice/#{id}"

            expect(response.content_type).to include("text/html")
            expect(response).to render_template("accounting/invoice")
          end
        end

        context "with posted status" do
          let(:invoice) { create(:accounting_invoice, status: :posted) }

          it "raises UnprocessableEntityError" do
            expect {
              get "/accounting/prints/unpublished_invoice/#{id}"
            }.to raise_error(Error::UnprocessableEntityError, "Invoice must be in draft or voided status")
          end
        end
      end

      context "when invoice does not exist" do
        let(:id) { -1 }

        it "raises UnprocessableEntityError" do
          expect {
            get "/accounting/prints/unpublished_invoice/#{id}"
          }.to raise_error(Error::UnprocessableEntityError, "No invoice found for this id")
        end
      end
    end

    context "when microservice env is not set" do
      before do
        allow(ENV).to receive(:[]).and_call_original
        allow(ENV).to receive(:[]).with("RAILS_PRINT_MICROSERVICE").and_return(nil)
      end

      it "raises UnprocessableEntityError" do
        expect {
          get "/accounting/prints/unpublished_invoice/#{id}"
        }.to raise_error(Error::UnprocessableEntityError, "This endpoint is only available in the print microservice")
      end
    end
  end
end
