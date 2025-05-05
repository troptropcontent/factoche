require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

RSpec.describe Api::V1::Organization::InvoicesController, type: :request do
  path '/api/v1/organization/companies/{company_id}/invoices' do
    get 'Lists invoices for an order' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer
      parameter name: 'status',
      in: :query,
        schema: {
          type: :array,
          items: {
            type: :string,
            enum: [ 'draft', 'posted', 'cancelled', 'voided' ]
          }
        }
        parameter name: 'order_id',
        in: :query,
          schema: {
            type: :integer
          }

        let(:order_id) { nil }
        let(:company_id) { company.id }
        let(:user) { FactoryBot.create(:user) }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }


        include_context 'a company with an order'

      response '200', 'invoices found' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Invoices::IndexDto.to_schema

        context "when there are no invoices" do
          run_test!("it returns an empty array") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"]).to eq([])
          end
        end

        context "when there are invoices" do
          let(:proforma) { ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data }
          let!(:invoice) { ::Accounting::Proformas::Post.call(proforma.id).data }

          run_test!("it returns the invoices") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results", 0)).to include({ "id"=> invoice.id })
          end
        end

        describe "when the company_id does not belong to a company the user is a member of" do
          let(:proforma) { ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data }
          let!(:invoice) { ::Accounting::Proformas::Post.call(proforma.id).data }
          let(:company_id) { FactoryBot.create(:company).id }

          run_test!("it returns an empty array") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"]).to eq([])
          end
        end

        context "when status are provided in the query params" do
          let(:status) { [ "cancelled" ] }

          let(:first_proforma) { ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data }
          let!(:first_invoice) { ::Accounting::Proformas::Post.call(first_proforma.id).data }
          let(:second_proforma) { ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data }
          let(:second_invoice) { ::Accounting::Proformas::Post.call(second_proforma.id).data }
          let!(:second_invoice_credit_note) { ::Accounting::Invoices::Cancel.call(second_invoice.id).data[:credit_note] }


          run_test!("it returns the filtered invoices") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results", 0, "number")).to eq(second_invoice.number)
            expect(parsed_response.dig("results").length).to eq(1)
          end
        end

        context "when order_id is provided in the query params" do
          context "when the order_id correctly belongs to an order of the company" do
            let(:order_id) { order.id }

            let(:proforma_related_to_order) { ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data }
            let!(:invoice_related_to_order) { ::Accounting::Proformas::Post.call(proforma_related_to_order.id).data }

            let(:another_quote) { FactoryBot.create(:quote, :with_version, company: company, client: client, number: 2) }
            let(:another_draft_order) { FactoryBot.create(:draft_order, :with_version, company: company, client: client, original_project_version: another_quote.last_version, number: 2) }
            let(:another_order) { FactoryBot.create(:order, :with_version, company: company, client: client, original_project_version: another_draft_order.last_version, number: 2) }
            let(:proforma_not_related_to_order) { ::Organization::Proformas::Create.call(another_order.versions.last.id, { invoice_amounts: [ { original_item_uuid: another_order.last_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data }
            let!(:invoice_not_related_to_order) { ::Accounting::Proformas::Post.call(proforma_not_related_to_order.id).data }


            run_test!("it returns the filtered invoices") do
              parsed_response = JSON.parse(response.body)
              expect(parsed_response.dig("results", 0, "number")).to eq(invoice_related_to_order.number)
              expect(parsed_response.dig("results").length).to eq(1)
            end
          end
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end

  path '/api/v1/organization/invoices/{id}' do
    get 'Show invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      include_context 'a company with an order'

      let(:proforma) { ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data }
      let!(:invoice) { ::Accounting::Proformas::Post.call(proforma.id).data }

      let(:id) { invoice.id }
      let(:user) { FactoryBot.create(:user) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }

      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      response '200', 'invoice found' do
        schema Organization::Invoices::ShowDto.to_schema

        run_test!
      end

      response '404', 'invoice not found' do
        describe "when the invoice does not exists" do
          let(:id) { -1 }

          run_test!
        end
      end

      response '401', 'unauthorised' do
        describe "when the invoice does not belong to a company the user is a member of" do
          let(:Authorization) { access_token(FactoryBot.create(:user)) }

          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end

  path '/api/v1/organization/invoices/{id}/cancel' do
    post 'Cancels an invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer, required: true

      include_context 'a company with an order'

      let(:proforma) { ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data }
      let!(:invoice) { ::Accounting::Proformas::Post.call(proforma.id).data }

      let(:id) { invoice.id }
      let(:user) { FactoryBot.create(:user) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }

      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      response '200', 'invoice cancelled' do
        schema Organization::Invoices::ShowDto.to_schema

        it "cancels the invoice and creates a credit note" do |example|
          expect {
            submit_request(example.metadata)
          }.to change { invoice.reload.status }.from("posted").to("cancelled")
          .and change(Accounting::CreditNote, :count).by(1)

          assert_response_matches_metadata(example.metadata)
        end
      end

      response '404', 'invoice not found' do
        context "when the invoice does not exist" do
          let(:id) { -1 }

          run_test!
        end
      end

      response '401', 'unauthorised' do
        context "when the invoice does not belong to a company the user is a member of" do
          let(:Authorization) { access_token(FactoryBot.create(:user)) }

          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        before { ::Accounting::Invoices::Cancel.call(invoice.id) }

        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema ApiError.schema

        context "when the invoice is not in posted status" do
          run_test! do |response|
            expect(response.body).to include("Cannot cancel invoice that is not in posted status")
          end
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
end
