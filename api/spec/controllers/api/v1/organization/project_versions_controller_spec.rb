require "rails_helper"
require "swagger_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_items"
RSpec.describe Api::V1::Organization::ProjectVersionsController, type: :request do
  path "/api/v1/organization/companies/{company_id}/orders/{order_id}/versions" do
    get "List all the order's versions" do
      tags "Project versions"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :order_id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      include_context 'a company with a project with three items'
      let!(:member) { FactoryBot.create(:member, user:, company:) }

      let(:company_id) { company.id }
      let(:order_id) { project.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      response "200", "list company's orders" do
        schema Organization::ProjectVersionIndexResponseDto.to_schema

        context "when the order correctly belong to the company" do
          run_test!("It returns all the order versions") {
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results", 0, "id")).to eq(project_version.id)
            expect(parsed_response.dig("results").length).to eq(1)
          }
        end

        context "when the order does not exists" do
          let(:order_id) { 123123123123123123123123 }

          run_test!("It returns an empty array") {
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results").length).to eq(0)
          }
        end

        context "when the order does not belong to the company" do
          let(:another_company) { FactoryBot.create(:company) }
          let(:another_client) { FactoryBot.create(:client, company: another_company) }
          let(:another_order) { FactoryBot.create(:quote, client: another_client, company: another_company) }
          let(:order_id) { another_order.id }


          run_test!("It returns an empty array") {
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results").length).to eq(0)
          }
        end
      end

      response "401", "not authorised" do
        context "when the user is not a member of the company" do
          let(:another_user) { FactoryBot.create(:user) }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(another_user.id)}" }

          run_test!
        end
      end

      response "404", "not found" do
        context "when the company does not exists" do
          let(:company_id) { 123123123123123123123123 }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

          run_test!
        end
      end
    end
  end

  path "/api/v1/organization/companies/{company_id}/orders/{order_id}/versions/{id}" do
    get "Show the order version details" do
      tags "Project versions"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :order_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }

      include_context 'a company with a project with three items'

      let(:another_company) { FactoryBot.create(:company) }
      let(:another_client) { FactoryBot.create(:client, company: another_company) }
      let!(:another_company_order) { FactoryBot.create(:quote, client: another_client, company: another_company) }
      let!(:another_company_project_version) { FactoryBot.create(:project_version, project: another_company_order) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:order_id) { project.id }
      let(:id) { project_version.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      response "200", "show order version details" do
        schema Organization::ProjectVersions::ShowDto.to_schema
        run_test!("It return the order version details") {
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("result", "id")).to eq(project_version.id)
            expect(parsed_response.dig("result", "retention_guarantee_rate")).to eq(project_version.retention_guarantee_rate.to_s)
        }
      end

      response "401", "not authorised" do
        context "when the user is not a member of the company" do
          let(:another_user) { FactoryBot.create(:user) }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(another_user.id)}" }

          run_test!
        end
      end

      response "404", "not found" do
        context "when the company does not exists" do
          let(:company_id) { 123123123123123123123123 }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

          run_test!
        end

        context "when the order does not exists" do
          let(:order_id) { 123123123123123123123123 }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

          run_test!
        end

        context "when the id does not exists within the order versions" do
          let(:order_id) { another_company_project_version.id }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

          run_test!
        end
      end
    end
  end
end
