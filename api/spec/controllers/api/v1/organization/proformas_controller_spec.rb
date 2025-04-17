require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
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
end
