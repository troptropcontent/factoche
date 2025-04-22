require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
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
      include_context 'a company with a project with three items'

      response '200', 'invoices found' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Invoices::IndexDto.to_schema

        context "when there are no invoices attached to the order" do
          run_test!("it returns an empty array") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"]).to eq([])
          end
        end

        context "when there are invoices attached to the order" do
         let!(:previous_invoice) {
            ::Organization::Invoices::Create.call(project_version.id, { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" } ] }).data
          }

          run_test!("it returns the invoices") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results", 0)).to include({ "id"=> previous_invoice.id })
          end
        end

        describe "when the company_id does not belong to a company the user is a member of" do
          let(:company_id) { FactoryBot.create(:company).id }

          run_test!("it returns an empty array") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"]).to eq([])
          end
        end

        context "when status are provided in the query params" do
          let(:status) { [ "voided" ] }

          before do
            FactoryBot.create(:invoice, company_id: company.id, holder_id: project_version.id, number: "PRO-2024-00001")
            FactoryBot.create(:invoice, :voided, company_id: company.id, holder_id: project_version.id, number: "PRO-2024-00002")
            FactoryBot.create(:invoice, :posted, company_id: company.id, holder_id: project_version.id, number: "INV-2024-00001")
            FactoryBot.create(:invoice, :cancelled, company_id: company.id, holder_id: project_version.id, number: "INV-2024-00002")
          end

          run_test!("it returns the filtered invoices") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results", 0, "number")).to eq("PRO-2024-00002")
            expect(parsed_response.dig("results").length).to eq(1)
          end
        end

        context "when order_id is provided in the query params" do
          context "when the order_id correctly belongs to an order of the company" do
            let(:order_id) { order.id }

            before do
              # previous invoice related to order
              FactoryBot.create(:invoice, company_id: company.id, holder_id: project_version.id, number: "PRO-2024-00001")

              # previous invoice related to another_order
              FactoryBot.create(:invoice, company_id: company.id, holder_id: "another_holder_id", number: "PRO-2024-00002")
            end

            run_test!("it returns the filtered invoices") do
              parsed_response = JSON.parse(response.body)
              expect(parsed_response.dig("results", 0, "number")).to eq("PRO-2024-00001")
              expect(parsed_response.dig("results").length).to eq(1)
            end
          end
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
  path '/api/v1/organization/companies/{company_id}/invoices/{id}' do
    get 'Show invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer

      let(:invoice) { ::Organization::Invoices::Create.call(project_version.id, { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" } ] }).data }
      let(:id) { invoice.id }
      let(:company_id) { company.id }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      include_context 'a company with a project with three items'

      response '200', 'invoice found' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Invoices::ShowDto.to_schema

        run_test!
      end

      response '404', 'invoice not found' do
        describe "when the company is not a company the user is a member of" do
          run_test!
        end

        describe "when the invoice does not belong to company" do
          let!(:member) { FactoryBot.create(:member, user:, company:) }
          let(:another_company) { FactoryBot.create(:company, :with_config) }
          let(:another_company_client) { FactoryBot.create(:client, company: another_company) }
          let(:another_company_quote) { FactoryBot.create(:quote, client: another_company_client, company: another_company) }
          let(:another_company_quote_version) { FactoryBot.create(:project_version, project: another_company_quote) }
          let(:another_company_project) { FactoryBot.create(:order, client: another_company_client, company: another_company, original_project_version: another_company_quote_version) }
          let(:another_company_project_version) { FactoryBot.create(:project_version, project: another_company_project) }
          let(:another_company_project_version_item) { FactoryBot.create(:item, project_version: another_company_project_version) }
          let!(:another_company_invoice) {
            ::Organization::Invoices::Create.call(another_company_project_version.id, { invoice_amounts: [ { original_item_uuid: another_company_project_version_item.original_item_uuid, invoice_amount: "0.2" } ] }).data
          }
          let(:id) { another_company_invoice.id }

          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
  path '/api/v1/organization/companies/{company_id}/invoices/{id}/cancel' do
    post 'Cancels an invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'

      parameter name: :company_id, in: :path, type: :integer, required: true
      parameter name: :id, in: :path, type: :integer, required: true

      let(:invoice) {
        draft = Organization::Invoices::Create.call(project_version.id, {
          invoice_amounts: [
            { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" }
          ]
        }).data
        Accounting::Invoices::Post.call(draft.id).data
      }
      let(:id) { invoice.id }
      let(:company_id) { company.id }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      include_context 'a company with a project with three items'

      response '200', 'invoice cancelled' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
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
        context "when the company is not a company the user is a member of" do
          run_test!
        end

        context "when the invoice does not exist" do
          let(:id) { -1 }
          let!(:member) { FactoryBot.create(:member, user:, company:) }

          run_test!
        end

        describe "when the invoice does not belong to company" do
          let!(:member) { FactoryBot.create(:member, user:, company:) }

          let(:another_company) { FactoryBot.create(:company, :with_config) }
          let(:another_company_client) { FactoryBot.create(:client, company: another_company) }
          let(:another_company_quote) { FactoryBot.create(:quote, client: another_company_client, company: another_company) }
          let(:another_company_quote_version) { FactoryBot.create(:project_version, project: another_company_quote) }
          let(:another_company_project) { FactoryBot.create(:order, client: another_company_client, company: another_company, original_project_version: another_company_quote_version) }
          let(:another_company_project_version) { FactoryBot.create(:project_version, project: another_company_project) }
          let(:another_company_project_version_item) { FactoryBot.create(:item, project_version: another_company_project_version) }
          let!(:another_company_invoice) {
            ::Organization::Invoices::Create.call(another_company_project_version.id, { invoice_amounts: [ { original_item_uuid: another_company_project_version_item.original_item_uuid, invoice_amount: "0.2" } ] }).data
          }
          let(:id) { another_company_invoice.id }

          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        before { invoice.update(status: :draft, number: "PRO-2024-0001") }

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
