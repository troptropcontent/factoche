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
         let!(:previous_invoice) { ::Organization::Invoices::CompletionSnapshots::Create.call(project_version.id, { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" } ] }).data }

          run_test!("it return the invoices") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results", 0)).to include({ "id"=> previous_invoice.id })
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
  end
  path '/api/v1/organization/projects/{project_id}/invoices/{id}' do
    get 'Show invoice' do
      tags 'Invoices'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :project_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer

      let(:invoice) { ::Organization::Invoices::CompletionSnapshots::Create.call(project_version.id, { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" } ] }).data }
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
                invoice_amount: { type: :number }
              }
            }
          }
        }
      }

      let!(:invoice) {
        ::Organization::Invoices::CompletionSnapshots::Create.call(project_version.id, { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" }, { original_item_uuid: second_item.original_item_uuid, invoice_amount: "0.2" } ] }).data
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

        it "Updates the invoice" do |example|
          expect { submit_request(example.metadata) }
            .to change { invoice.reload.lines.sum('excl_tax_amount') }.from(0.4).to(1)

          assert_response_matches_metadata(example.metadata)
        end

        context "when the client have changed" do
          before { client.update(name: "New Client Name") }

          it "Updates the invoice details accordingly" do |example|
            expect { submit_request(example.metadata) }
              .to change { invoice.reload.detail.client_name }.from("Super Client").to("New Client Name")

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
          before { invoice.update(status: :posted, number: "INV-000") }

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
  end
end
