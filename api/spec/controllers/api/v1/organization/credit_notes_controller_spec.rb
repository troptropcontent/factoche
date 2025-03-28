require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
RSpec.describe Api::V1::Organization::CreditNotesController, type: :request do
  path '/api/v1/organization/companies/{company_id}/credit_notes' do
    get 'Lists company\'s credit notes' do
      tags 'Credit Notes'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer
      let(:company_id) { company.id }
      let(:user) { FactoryBot.create(:user) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      include_context 'a company with a project with three items'

      response '200', 'credit notes found' do
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        schema Organization::CreditNotes::IndexDto.to_schema

        context "when there are no credit notes attached to the order" do
          run_test!("it returns an empty array") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"]).to eq([])
          end
        end

        context "when there are credit notes attached to the order" do
         let!(:posted_invoice) {
            draft = ::Organization::Invoices::Create.call(project_version.id, { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" } ] }).data
            ::Accounting::Invoices::Post.call(draft.id).data
          }

          let!(:credit_note) {
            Accounting::Invoices::Cancel.call(posted_invoice.id).data[:credit_note]
          }

          run_test!("it returns the credit notes") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results", 0)).to include({ "id"=> credit_note.id })
          end
        end

        describe "when the company_id does not belong to a company the user is a member of" do
          let!(:posted_invoice) {
            draft = ::Organization::Invoices::Create.call(project_version.id, { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.2" } ] }).data
            ::Accounting::Invoices::Post.call(draft.id).data
          }

          let!(:credit_note) {
            Accounting::Invoices::Cancel.call(posted_invoice.id).data[:credit_note]
          }

          let(:company_id) { FactoryBot.create(:company).id }

          run_test!("it returns an empty array") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response["results"]).to eq([])
          end
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
end
