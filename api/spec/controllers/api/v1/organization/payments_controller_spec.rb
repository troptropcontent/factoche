require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"
require 'support/shared_contexts/organization/projects/a_company_with_some_orders'

RSpec.describe Api::V1::Organization::PaymentsController, type: :request do
  path '/api/v1/organization/payments' do
    post 'Creates an new payment' do
      tags 'Payments'
      security [ bearerAuth: [] ]
      produces 'application/json'
      consumes 'application/json'

      parameter name: :body, in: :body, required: true, schema: {
        type: :object,
        required: [ :invoice_id ],
        properties: {
          invoice_id: {
            type: :integer
          }
        }
      }

      include_context 'a company with some orders', number_of_orders: 2

      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
      let(:invoice) {
          proforma = ::Organization::Proformas::Create.call(first_order.last_version.id, {
            invoice_amounts: [
              { original_item_uuid: first_order.last_version.items.first.original_item_uuid, invoice_amount: 1 },
              { original_item_uuid: first_order.last_version.items.second.original_item_uuid, invoice_amount: 2 }
            ]
          }).data
          ::Accounting::Proformas::Post.call(proforma.id).data
      }

      let(:invoice_id) { invoice.id }
      let(:body) { { invoice_id: invoice_id } }

      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { access_token(user) }

      response '201', 'successfully creates completion snapshot invoice' do
        schema Accounting::Payments::ShowDto.to_schema

        let!(:member) { FactoryBot.create(:member, user:, company:) }

        it("creates an payment for the full amount due of the invoice", :aggregate_failures) do |example|
          expect { submit_request(example.metadata) }.to change(Accounting::Payment, :count).by(1)

          assert_response_matches_metadata(example.metadata)

          parsed_response = JSON.parse(response.body)
          expect(parsed_response.dig("result", "amount")).to eq("3.42") # 3 + 20 % (VAT) - 5 %  (RETENTION GUARANTEE)
        end
      end

      it_behaves_like "an authenticated endpoint"

      response '401', 'unauthorized' do
        let(:invoice_id) { invoice.id }

        context "when the invoice does not belong to a company the user is a member of" do
          run_test!
        end
      end

      response '404', 'not_found' do
        let(:invoice_id) { -1 }

        context "when the order does not exists" do
          run_test!
        end
      end
    end
  end
end
