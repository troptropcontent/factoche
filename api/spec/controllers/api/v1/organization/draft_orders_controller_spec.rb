require "rails_helper"
require "swagger_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"
require_relative "shared_examples/an_authenticated_endpoint"

module Api
  module V1
    module Organization
      RSpec.describe DraftOrdersController, type: :request do
        path "/api/v1/organization/companies/{company_id}/draft_orders" do
          get "List all the company's draft orders" do
            tags "Draft Orders"
            security [ bearerAuth: [] ]
            consumes "application/json"
            produces "application/json"
            parameter name: :company_id, in: :path, type: :integer

            let(:user) { FactoryBot.create(:user) }
            let!(:member) { FactoryBot.create(:member, user:, company:) }

            include_context 'a company with a project with three item groups'

            let(:company_id) { company.id }
            let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

            response "200", "list company's draft orders" do
              schema ::Organization::Projects::DraftOrders::IndexDto.to_schema
              run_test! {
                parsed_response = JSON.parse(response.body)
                expect(parsed_response["results"].length).to eq(1)
                expect(parsed_response.dig("results", 0, "id")).to eq(draft_order.id)
              }

              context "when the user is not a member of the company" do
                let(:another_user) { FactoryBot.create(:user) }
                let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(another_user.id)}" }

                run_test!("It returns an empty array") {
                  parsed_response = JSON.parse(response.body)
                  expect(parsed_response["results"].length).to eq(0)
                }
              end

              context "when the company does not exist" do
                let(:company_id) { 123123123123123123123123 }
                let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

                run_test!("It returns an empty array") {
                  parsed_response = JSON.parse(response.body)
                  expect(parsed_response["results"].length).to eq(0)
                }
              end
            end
          end
        end

        path "/api/v1/organization/draft_orders/{id}" do
          get "Show draft order details" do
            tags "Draft Orders"
            security [ bearerAuth: [] ]
            produces "application/json"
            parameter name: :id, in: :path, type: :integer

            let(:user) { FactoryBot.create(:user) }
            let!(:member) { FactoryBot.create(:member, user:, company:) }

            include_context 'a company with a project with three item groups'

            let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
            let(:id) { draft_order.id }

            response "200", "show draft order details" do
              schema ::Organization::Projects::DraftOrders::ShowDto.to_schema
              run_test! {
                parsed_response = JSON.parse(response.body)
                expect(parsed_response.dig("result", "id")).to eq(draft_order.id)
              }
            end

            response "404", "draft order not found" do
              context "when the user is not a member of the company" do
                let(:another_user) { FactoryBot.create(:user) }
                let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(another_user.id)}" }

                run_test!
              end

              context "when the draft order does not exist" do
                let(:id) { 123123123123123123123123 }
                let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

                run_test!
              end
            end
          end
        end
      end
    end
  end
end
