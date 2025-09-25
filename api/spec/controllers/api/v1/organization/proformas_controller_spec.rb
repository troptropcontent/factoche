require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

RSpec.describe Api::V1::Organization::ProformasController, type: :request do
  path '/api/v1/organization/orders/{order_id}/proformas' do
    post 'Creates an invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      consumes 'application/json'

      parameter name: :order_id, in: :path, type: :integer, required: true
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

      let(:order_id) { 1 }
      let(:body) { }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      include_context 'a company with a project with three items'
      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }

      response '200', 'successfully creates completion snapshot invoice' do
        schema Organization::Proformas::ShowDto.to_schema
        let!(:member) { FactoryBot.create(:member, user:, company:) }

        let(:order_id) { order.id }
        let(:body) { { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.5" } ] } }

        it("creates an invoice, its detail and its line and returns it") do |example|
          expect { submit_request(example.metadata) }.to change(Accounting::Proforma, :count).by(1)
          .and change(Accounting::FinancialTransactionDetail, :count).by(1)
          .and change(Accounting::FinancialTransactionLine, :count).by(1)

          assert_response_matches_metadata(example.metadata)
        end
      end

      it_behaves_like "an authenticated endpoint"

      response '401', 'unauthorized' do
        let(:order_id) { order.id }

        context "when the order does not belong to a company the user is a member of" do
          run_test!
        end
      end

      response '404', 'not_found' do
        let(:order_id) { -1 }

        context "when the order does not exists" do
          run_test!
        end
      end
    end
  end
  path '/api/v1/organization/companies/{company_id}/proformas' do
    get 'Lists invoices for an order' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer
      parameter name: 'order_id',
        in: :query,
        schema: {
          type: :integer
        }

      let(:order_id) { nil }
      let(:company_id) { company.id }
      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      include_context 'a company with an order'

      response '200', 'invoices found' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema ::Organization::Proformas::IndexDto.to_schema

        context "when there are no invoices attached to the order" do
          run_test!("it returns an empty array") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"]).to eq([])
          end
        end

        context "when there are invoices attached to the order" do
          before {
            Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data
          }

          run_test!("it returns the invoices") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"].count).to eq(1)
            expect(parsed_response.dig("results", 0)).to include({ "number"=> "PRO-#{Time.current.year}-#{Time.current.month.to_s.rjust(2, "0")}-000001" })
          end
        end

        describe "when the company_id does not belong to a company the user is a member of" do
          let(:company_id) { FactoryBot.create(:company).id }

          before {
            Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data
          }

          run_test!("it returns an empty array") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"]).to eq([])
          end
        end

        context "when order_id is provided in the query params" do
          context "when the order_id correctly belongs to an order of the company" do
            let(:order_id) { order.id }

            before do
              # another order
              another_quote = FactoryBot.create(:quote, :with_version, company: company, client: client, number: 2, bank_detail: company.bank_details.first)
              another_draft_order = FactoryBot.create(:draft_order, :with_version, company: company, client: client, original_project_version: another_quote.last_version, number: 2, bank_detail: company.bank_details.first)
              another_order = FactoryBot.create(:order, :with_version, company: company, client: client, original_project_version: another_draft_order.last_version, number: 2, bank_detail: company.bank_details.first)

              # A proforma from another order
              another_order_proforma = Organization::Proformas::Create.call(another_order.last_version.id, { invoice_amounts: [ { original_item_uuid: another_order.last_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data

              # An invoice from another order
              Accounting::Proformas::Post.call(another_order_proforma.id).data.persisted?

              # A proforma related to the order
              order_proforma = Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data

              # An invoice related to the order
              Accounting::Proformas::Post.call(order_proforma.id).data.persisted?
            end

            run_test!("it returns the filtered invoices") do
              parsed_response = JSON.parse(response.body)
              expect(parsed_response.dig("results", 0, "number")).to eq("PRO-#{Time.current.year}-#{Time.current.month.to_s.rjust(2, "0")}-000002")
              expect(parsed_response.dig("results").length).to eq(1)
            end
          end
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
  path '/api/v1/organization/proformas/{id}' do
    get 'Show invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      include_context 'a company with an order'

      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
      let(:proforma) { ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data }
      let(:id) { proforma.id }
      let(:company_id) { company.id }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { access_token(user) }
      include_context 'a company with a project with three items'

      response '200', 'proforma found' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Proformas::ShowDto.to_schema

        run_test!
      end

      response '401', 'unauthorised' do
        describe "when the company is not a company the user is a member of" do
          run_test!
        end
      end

      response '404', 'not_found' do
        describe "when the proforma does not exists" do
          let(:id) { -1 }

          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end

    put 'Update proforma' do
      tags 'Proformas'
      security [ bearerAuth: [] ]
      produces 'application/json'
      consumes 'application/json'
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

      include_context 'a company with an order'

      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
      let!(:proforma) {
        ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" }, { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: "0.2" } ] }).data
      }
      let(:id) { proforma.id }
      let(:user) { FactoryBot.create(:user) }

      let(:Authorization) { "Bearer #{access_token(user)}" }
      let(:body) { { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "1" } ] } }

      response '200', 'Proforma updated' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Proformas::ShowDto.to_schema

        it "Updates the proforma by voiding the proforma and creating a new one", :aggregate_failures do |example|
          expect { submit_request(example.metadata) }
            .to change(Accounting::Proforma, :count).by(1)
            .and change(Accounting::FinancialTransactionDetail, :count).by(1)
            .and change(Accounting::FinancialTransactionLine, :count).by(1)

          assert_response_matches_metadata(example.metadata)

          parsed_response = JSON.parse(response.body)

          expect(parsed_response.dig("result", "id")).not_to eq(proforma.id)
          expect(parsed_response.dig("result", "status")).to eq("draft")
          expect(parsed_response.dig("result", "number")).to end_with("002")
        end

        context "when the client has changed" do
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
        describe "when the proforma does not exists" do
          let(:id) { -1 }

          run_test!
        end
      end

      response '401', 'unathorised' do
        describe "when the proforma does not belong to a company the user is a member of" do
          let(:Authorization) { "Bearer #{access_token(FactoryBot.create(:user))}" }

          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }

        context "when the invoice is not draft" do
          before { proforma.update(status: :posted) }

          run_test!
        end

        context "when the invoice_amount would exceed the total amount allowed in the order for the item" do
          let(:body) { { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "100000" } ] } }

          run_test!
        end

        context "when the original_item_uuid does not belong to the order" do
          let(:body) { { invoice_amounts: [ { original_item_uuid: "another_id", invoice_amount: "1" } ] } }

          run_test!
        end

        context "when the params are not valid" do
          let(:body) { { invoice_amounts: [ { invoice_amount: "1" } ] } }

          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end

    delete 'Voids an invoice' do
      tags 'Proformas'
      security [ bearerAuth: [] ]
      produces 'application/json'

      parameter name: :id, in: :path, type: :integer, required: true

      include_context 'a company with an order'

      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
      let(:proforma) {
        Organization::Proformas::Create.call(order_version.id, {
          invoice_amounts: [
            { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" }
          ]
        }).data
      }
      let(:id) { proforma.id }

      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { access_token(user) }

      response '200', 'proforma voided' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::Proformas::ShowDto.to_schema

        it "voids the proforma" do |example|
          expect {
            submit_request(example.metadata)
          }.to change { proforma.reload.status }.from("draft").to("voided")

          assert_response_matches_metadata(example.metadata)
        end
      end

      response '404', 'not found' do
        schema ApiError.schema

        context "when the proforma does not exist" do
          let(:id) { -1 }
          let!(:member) { FactoryBot.create(:member, user:, company:) }

          run_test!
        end
      end

      response '401', 'unauthorised' do
        schema ApiError.schema

        context "when the proforma does not belong to a company the user is a member of" do
          let(:Authorization) { access_token(FactoryBot.create(:user)) }

          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema ApiError.schema

        context "when the proforma is not in draft status" do
          before do
            proforma.update!(status: :posted)
          end

          run_test! do |response|
            expect(response.body).to include("Failed to void proforma: Cannot void a proforma that is not in draft status")
          end
        end
      end

      it_behaves_like "an authenticated endpoint"
    end

    post 'Post proforma' do
      tags 'Proformas'
      security [ bearerAuth: [] ]
      produces 'application/json'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :integer
      parameter name: :body, in: :body, schema: {
              type: :object,
              properties: {
                issue_date: { type: :string }
              }
            }

      include_context 'a company with an order'

      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
      let!(:proforma) {
        ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" }, { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: "0.2" } ] }).data
      }
      let(:id) { proforma.id }

      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { access_token(user) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }

      response '200', 'invoice posted' do
        schema Organization::Proformas::ShowDto.to_schema

        it "Posts the proforma by voiding the proforma and creating a new instance of Invoice at the proforma date", :aggregate_failures do |example|
          expect { submit_request(example.metadata) }
            .to change(Accounting::Invoice, :count).by(1)
            .and change(Accounting::FinancialTransactionDetail, :count).by(1)
            .and change(Accounting::FinancialTransactionLine, :count).by(2)

          assert_response_matches_metadata(example.metadata)

          parsed_response = JSON.parse(response.body)

          expect(parsed_response.dig("result", "id")).not_to eq(proforma.id)
          expect(parsed_response.dig("result", "status")).to eq("posted")
          expect(parsed_response.dig("result", "number")).to end_with("001")
          expect(Date.parse(parsed_response.dig("result", "issue_date"))).to eq(proforma.issue_date.to_date)
        end

        context "when an issue_date is provided" do
          let(:body) { { issue_date: (Date.current - 2.days).strftime("%d-%m-%Y") } }

           it "Posts the proforma by voiding the proforma and creating a new instance of Invoice with the provided issue_date", :aggregate_failures do |example|
          expect { submit_request(example.metadata) }
            .to change(Accounting::Invoice, :count).by(1)
            .and change(Accounting::FinancialTransactionDetail, :count).by(1)
            .and change(Accounting::FinancialTransactionLine, :count).by(2)

          assert_response_matches_metadata(example.metadata)

          parsed_response = JSON.parse(response.body)

          expect(parsed_response.dig("result", "id")).not_to eq(proforma.id)
          expect(parsed_response.dig("result", "status")).to eq("posted")
          expect(parsed_response.dig("result", "number")).to end_with("001")
          expect(Date.parse(parsed_response.dig("result", "issue_date"))).to eq(Date.current - 2.days)
        end
        end
      end

      response '404', 'invoice not found' do
        context "when the proforma does not exist" do
          let(:id) { -1 }

          run_test!
        end
      end

      response '401', 'unauthorised' do
        context "when the proforma does not belogn to a company the user is a member of" do
          let(:Authorization) { access_token(FactoryBot.create(:user)) }

          run_test!
        end
      end

      response '422', 'unprocessable entity' do
        context "when the invoice is not draft" do
          before { proforma.update(status: :posted) }

          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
end
