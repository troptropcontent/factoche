require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

module Api
  module V1
    module Organization
      RSpec.describe CreditNotesController, type: :request do
        path '/api/v1/organization/companies/{company_id}/credit_notes' do
          get 'Lists company\'s credit notes' do
            tags 'Credit Notes'
            security [ bearerAuth: [] ]
            produces 'application/json'
            parameter name: :company_id, in: :path, type: :integer
            let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
            let(:company_id) { company.id }
            let(:user) { FactoryBot.create(:user) }
            let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
            include_context 'a company with an order'

            response '200', 'credit notes found' do
              let!(:member) { FactoryBot.create(:member, user:, company:) }
              schema ::Organization::CreditNotes::IndexDto.to_schema

              context "when there are no credit notes" do
                run_test!("it returns an empty array") do
                  parsed_response = JSON.parse(response.body)
                  expect(parsed_response["results"]).to eq([])
                end
              end

              context "when there are credit notes" do
                let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
                let(:proforma) do
                  ::Organization::Proformas::Create.call(order_version.id, {
                    invoice_amounts: [
                      { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 1 },
                      { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 2 }
                    ]
                  }).data
                end

                let(:invoice) { ::Accounting::Proformas::Post.call(proforma.id).data }

                let!(:credit_note) { ::Accounting::Invoices::Cancel.call(invoice.id).data[:credit_note] }

                run_test!("it returns the credit notes") do
                  parsed_response = JSON.parse(response.body)
                  expect(parsed_response.dig("results", 0)).to include({ "id"=> credit_note.id })
                end
              end

              describe "when the company_id does not belong to a company the user is a member of" do
                let(:proforma) do
                  ::Organization::Proformas::Create.call(order_version.id, {
                    invoice_amounts: [
                      { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 1 },
                      { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 2 }
                    ]
                  }).data
                end

                let(:invoice) { ::Accounting::Proformas::Post.call(proforma.id).data }

                let!(:credit_note) { ::Accounting::Invoices::Cancel.call(invoice.id).data[:credit_note] }

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

        path '/api/v1/organization/credit_notes/{id}' do
          get 'Show credit note' do
            tags 'Credit Notes'
            security [ bearerAuth: [] ]
            produces 'application/json'
            parameter name: :id, in: :path, type: :integer

            let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
            let(:proforma) { ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data }
            let(:invoice) { ::Accounting::Proformas::Post.call(proforma.id).data }
            let(:credit_note) { ::Accounting::Invoices::Cancel.call(invoice.id).data[:credit_note] }

            let(:id) { credit_note.id }
            let(:user) { FactoryBot.create(:user) }
            let!(:member) { FactoryBot.create(:member, user:, company:) }

            let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

            include_context 'a company with an order'

            response '200', 'invoice found' do
              schema ::Organization::CreditNotes::ShowDto.to_schema

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
      end
    end
  end
end
