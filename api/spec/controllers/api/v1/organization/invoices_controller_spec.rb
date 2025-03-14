require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
RSpec.describe Api::V1::Organization::InvoicesController, type: :request do
  path '/api/v1/organization/projects/{project_id}/invoices' do
    get 'Lists invoices for a project' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :project_id, in: :path, type: :integer
      parameter name: 'status',
          in: :query,
          schema: {
            type: :array,
            items: {
              type: :string,
              enum: [ 'draft', 'posted', 'cancelled', 'voided' ]
            }
          }


      let(:project_id) { project.id }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      include_context 'a company with a project with three items'

      response '200', 'invoices found' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Invoices::IndexDto.to_schema

        context "when there is no invoices attached to the project" do
          run_test!("it return an empty array") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"]).to eq([])
          end
        end

        context "when there is invoices attached to the project" do
         let!(:previous_invoice) { ::Organization::Invoices::Create.call(project_version.id, { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" } ] }).data }

          run_test!("it return the invoices") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results", 0)).to include({ "id"=> previous_invoice.id })
          end
        end

        context "when status are provided in the query params" do
          let(:status) { [ "voided" ] }

          before do
            FactoryBot.create(:invoice, company_id: 1, holder_id: project_version.id, number: "PRO-2024-00001")
            FactoryBot.create(:invoice, :voided, company_id: 1, holder_id: project_version.id, number: "PRO-2024-00002")
            FactoryBot.create(:invoice, :posted, company_id: 1, holder_id: project_version.id, number: "INV-2024-00001")
            FactoryBot.create(:invoice, :cancelled, company_id: 1, holder_id: project_version.id, number: "INV-2024-00002")
          end

          run_test!("it return the filtered invoices") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results", 0, "number")).to eq("PRO-2024-00002")
            expect(parsed_response.dig("results").length).to eq(1)
          end
        end
      end

      response '404', 'project not found' do
        describe "when the project does npot belong to a company the user is a member of" do
          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end

    post 'Creates an invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      consumes 'application/json'

      parameter name: :project_id, in: :path, type: :integer, required: true
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        required: [ :invoice_amounts ],
        properties: {
          invoice_amounts: {
            type: :array,
            items: {
              type: :object,
              required: [ :original_item_uuid, :invoice_amount ],
              properties: {
                original_item_uuid: { type: :string },
                invoice_amount: { type: :string, format: "decimal" }
              }
            }
          }
        }
      }

      let(:project_id) { 1 }
      let(:body) { }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      include_context 'a company with a project with three items'

      response '200', 'successfully creates completion snapshot invoice' do
        schema Organization::Invoices::ShowDto.to_schema
        let!(:member) { FactoryBot.create(:member, user:, company:) }

        let(:project_id) { project.id }
        let(:body) { { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.5" } ] } }

        it("creates a invoice, its detail and its line and returns it") do |example|
          expect { submit_request(example.metadata) }.to change(Accounting::Invoice, :count).by(1)
          .and change(Accounting::FinancialTransactionDetail, :count).by(1)
          .and change(Accounting::FinancialTransactionLine, :count).by(1)

          assert_response_matches_metadata(example.metadata)
        end
      end

      it_behaves_like "an authenticated endpoint"

      response '404', 'not_found' do
        let(:project_id) { project.id }

        schema ApiError.schema

        context "when the project_version does not belong to a company the user is a member of" do
          run_test!
        end
      end
    end
  end
  path '/api/v1/organization/projects/{project_id}/invoices/{id}' do
    get 'Show invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :project_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer

      let(:invoice) { ::Organization::Invoices::Create.call(project_version.id, { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" } ] }).data }
      let(:id) { invoice.id }
      let(:project_id) { project.id }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      include_context 'a company with a project with three items'

      response '200', 'invoice found' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Invoices::ShowDto.to_schema

        run_test!
      end

      response '404', 'invoice not found' do
        describe "when the project does npot belong to a company the user is a member of" do
          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end

    put 'Update invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      consumes 'application/json'
      parameter name: :project_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer
      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        required: [ :invoice_amounts ],
        properties: {
          invoice_amounts: {
            type: :array,
            items: {
              type: :object,
              required: [ :original_item_uuid, :invoice_amount ],
              properties: {
                original_item_uuid: { type: :string },
                invoice_amount: { type: :string, format: "decimal" }
              }
            }
          }
        }
      }

      let!(:invoice) {
        ::Organization::Invoices::Create.call(project_version.id, { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" }, { original_item_uuid: second_item.original_item_uuid, invoice_amount: "0.2" } ] }).data
      }
      let(:id) { invoice.id }
      let(:project_id) { project.id }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let(:body) { { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "1" } ] } }
      include_context 'a company with a project with three items'

      response '200', 'invoice updated' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Invoices::ShowDto.to_schema

        it "Updates the invoice by voiding the invoice and creating a new one", :aggregate_failures do |example|
          expect { submit_request(example.metadata) }
            .to change(Accounting::Invoice, :count).by(1)
            .and change(Accounting::FinancialTransactionDetail, :count).by(1)
            .and change(Accounting::FinancialTransactionLine, :count).by(1)

          assert_response_matches_metadata(example.metadata)

          parsed_response = JSON.parse(response.body)

          expect(parsed_response.dig("result", "id")).not_to eq(invoice.id)
          expect(parsed_response.dig("result", "status")).to eq("draft")
          expect(parsed_response.dig("result", "number")).to end_with("002")
        end

        context "when the client have changed" do
          before { client.update(name: "New Client Name") }

          it "Updates the invoice details accordingly" do |example|
            submit_request(example.metadata)

            parsed_response = JSON.parse(response.body)

            expect(parsed_response.dig("result", "detail", "client_name")).to eq("New Client Name")

            assert_response_matches_metadata(example.metadata)
          end
        end
      end

      response '404', 'invoice not found' do
        describe "when the project does npot belong to a company the user is a member of" do
          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }

        context "when the invoice is not draftf" do
          before { invoice.update(status: :posted, number: "INV-2024-00001") }

          run_test!
        end

        context "when the invoice_amount would exceed the total amount allowed in the project for the item" do
          let(:body) { { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "100000" } ] } }

          run_test!
        end

        context "when the original_item_item does not belong to the project" do
          let(:body) { { invoice_amounts: [ { original_item_uuid: "antoher_id", invoice_amount: "1" } ] } }

          run_test!
        end

        context "when the params are not valid" do
          let(:body) { { invoice_amounts: [ { invoice_amount: "1" } ] } }

          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end

    post 'Post invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      consumes 'application/json'
      parameter name: :project_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer

      let!(:invoice) {
        ::Organization::Invoices::Create.call(project_version.id, { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" }, { original_item_uuid: second_item.original_item_uuid, invoice_amount: "0.2" } ] }).data
      }
      let(:id) { invoice.id }
      let(:project_id) { project.id }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      include_context 'a company with a project with three items'

      response '200', 'invoice posted' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Invoices::ShowDto.to_schema

        it "Posts the invoice by voiding the invoice and creating a new posted one", :aggregate_failures do |example|
          expect { submit_request(example.metadata) }
            .to change(Accounting::Invoice, :count).by(1)
            .and change(Accounting::FinancialTransactionDetail, :count).by(1)
            .and change(Accounting::FinancialTransactionLine, :count).by(2)

          assert_response_matches_metadata(example.metadata)

          parsed_response = JSON.parse(response.body)

          expect(parsed_response.dig("result", "id")).not_to eq(invoice.id)
          expect(parsed_response.dig("result", "status")).to eq("posted")
          expect(parsed_response.dig("result", "number")).to end_with("001")
        end
      end

      response '404', 'invoice not found' do
        describe "when the project does npot belong to a company the user is a member of" do
          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }

        context "when the invoice is not draftf" do
          before { invoice.update(status: :posted, number: "INV-2024-00001") }

          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
end
