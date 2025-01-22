require "rails_helper"
require "swagger_helper"

RSpec.describe Api::V1::Organization::ProjectsController, type: :request, focus: true do
  path "/api/v1/organization/companies/{company_id}/projects/{project_id}/versions" do
    get "List all the project's versions" do
      tags "Project versions"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :project_id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company) }
      let(:client) { FactoryBot.create(:client, company: company) }
      let(:company_project) { FactoryBot.create(:project, client: client,) }
      let(:company_project_version) { FactoryBot.create(:project_version, project: company_project) }
      let!(:company_project_version_item_group) { FactoryBot.create(:item_group, project_version: company_project_version, name: "Item Group", grouped_items_attributes: [ {
        name: "Item",
        unit: "U",
        position: 1,
        unit_price_cents: "1000",
        project_version: company_project_version,
        quantity: 2
      } ]) }
      let(:another_company) { FactoryBot.create(:company) }
      let(:another_client) { FactoryBot.create(:client, company: another_company) }
      let!(:another_company_project) { FactoryBot.create(:project, client: another_client,) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:project_id) { company_project.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      response "200", "list company's projects" do
        schema Organization::ProjectVersionIndexResponseDto.to_schema

        context "when the project correctly belong to the company" do
          run_test!("It returns all the project versions") {
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results", 0, "id")).to eq(company_project_version.id)
            expect(parsed_response.dig("results").length).to eq(1)
          }
        end

        context "when the project does not exists" do
          let(:project_id) { 123123123123123123123123 }

          run_test!("It returns an empty array") {
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("results").length).to eq(0)
          }
        end

        context "when the project does not belong to the company" do
          let(:project_id) { another_company_project.id }
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

  path "/api/v1/organization/companies/{company_id}/projects/{project_id}/versions/{id}" do
    get "Show the project version details" do
      tags "Project versions"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :project_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company) }
      let(:client) { FactoryBot.create(:client, company: company) }
      let(:company_project) { FactoryBot.create(:project, client: client) }
      let!(:company_project_version) { FactoryBot.create(:project_version, project: company_project) }
      let!(:company_project_version_item_group) {
        FactoryBot.create(:item_group, project_version: company_project_version, name: "Item Group", grouped_items_attributes: [ {
        name: "Item",
        unit: "U",
        position: 1,
        unit_price_cents: "1000",
        project_version: company_project_version,
        quantity: 2
      } ]) }
      let(:another_company) { FactoryBot.create(:company) }
      let(:another_client) { FactoryBot.create(:client, company: another_company) }
      let!(:another_company_project) { FactoryBot.create(:project, client: another_client,) }
      let!(:another_company_project_version) { FactoryBot.create(:project_version, project: another_company_project) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:project_id) { company_project.id }
      let(:id) { company_project_version.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      response "200", "show project version details" do
        schema Organization::ProjectVersionShowResponseDto.to_schema
        run_test!("It return the project version details") {
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("result", "id")).to eq(company_project_version.id)
            expect(parsed_response.dig("result", "retention_guarantee_rate")).to eq(company_project_version.retention_guarantee_rate)
            expect(parsed_response.dig("result", "item_groups", 0, "id")).to eq(company_project_version_item_group.id)
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
        context "when the project does not exists" do
          let(:project_id) { 123123123123123123123123 }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
          run_test!
        end
        context "when the id does not exists within the project versions" do
          let(:project_id) { another_company_project_version.id }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
          run_test!
        end
      end
    end
  end
end
