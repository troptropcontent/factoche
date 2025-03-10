require "rails_helper"
require "swagger_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
require_relative "../shared_examples/an_authenticated_endpoint"

module Api
  module V1
    module Organization
      module Invoices
        RSpec.describe CompletionSnapshotsController, type: :request do
          path '/api/v1/organization/project_versions/{project_version_id}/invoices/completion_snapshot' do
            post 'Creates a completion snapshot invoice' do
              tags 'Invoices'
              security [ bearerAuth: [] ]
              produces 'application/json'
              consumes 'application/json'

              parameter name: :project_version_id, in: :path, type: :integer, required: true
              parameter name: :completion_snapshot_invoice, in: :body, schema: ::Organization::Invoices::CompletionSnapshots::CreateDto.to_schema

              let(:project_version_id) { 1 }
              let(:completion_snapshot_invoice) { }
              let(:user) { FactoryBot.create(:user) }
              let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

              include_context 'a company with a project with three items'

              response '200', 'successfully creates completion snapshot invoice' do
                schema ::Organization::Invoices::CompletionSnapshots::ShowDto.to_schema
                let!(:member) { FactoryBot.create(:member, user:, company:) }

                let(:project_version_id) { project_version.id }
                let(:completion_snapshot_invoice) { { invoice_amounts: [ { original_item_uuid: first_item.original_item_uuid, invoice_amount: "0.5" } ] } }

                it("creates a invoice, its detail and its line and returns it") do |example|
                  expect { submit_request(example.metadata) }.to change(Accounting::CompletionSnapshotInvoice, :count).by(1)
                  .and change(Accounting::FinancialTransactionDetail, :count).by(1)
                  .and change(Accounting::FinancialTransactionLine, :count).by(3)

                  assert_response_matches_metadata(example.metadata)
                end
              end

              it_behaves_like "an authenticated endpoint"

              response '404', 'not_found' do
                let(:project_version_id) { project_version.id }

                schema ApiError.schema

                context "when the project_version does not belong to a company the user is a member of" do
                  run_test!
                end
              end
            end
          end
        end
      end
    end
  end
end
