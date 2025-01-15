require "rails_helper"
require "swagger_helper"

RSpec.describe Api::V1::Organization::ProjectsController, type: :request, focus: true  do
  path "/api/v1/organization/companies/{company_id}/projects" do
    post "Creates a new project and its descendants" do
      tags "Projects"
      security [ bearer_auth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :project, in: :body, schema: Organization::CreateProjectDto.to_schema

      response "200", "project created" do
        let(:user) { FactoryBot.create(:user) }
        let(:company) { FactoryBot.create(:company) }
        let!(:client) { FactoryBot.create(:client, company: company) }
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        let(:company_id) { company.id }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        schema Organization::ProjectDto.to_schema

        describe "simple project, without item groups" do
          let(:project) do
            {
              name: "Amazing Project",
              client_id: client.id,
              retention_guarantee_rate: 5,
              items: [
                {
                  name: "Screws",
                  unit: "ENS",
                  position: 1,
                  unit_price_cents: 1500,
                  quantity: 4
                },
                {
                  name: "Bolts",
                  unit: "ENS",
                  position: 2,
                  unit_price_cents: 2000,
                  quantity: 8
                }
              ]
            }
          end
          let!(:number_of_project_before) { Organization::Project.count }
          let!(:number_of_project_version_before) { Organization::ProjectVersion.count }
          let!(:number_of_items_before) { Organization::Item.count }
          let!(:number_of_item_groups_before) { Organization::ItemGroup.count }

          run_test! "create a new project with the relevant descendants" do
            expect(Organization::Project.count).to eq(number_of_project_before + 1)
            expect(Organization::ProjectVersion.count).to eq(number_of_project_version_before + 1)
            expect(Organization::Item.count).to eq(number_of_items_before + 2)
            expect(Organization::ItemGroup.count).to eq(number_of_item_groups_before + 0)
          end
        end

        describe "advanced project, with item groups" do
          let(:project) do
            {
              name: "Amazing Project",
              client_id: client.id,
              retention_guarantee_rate: 5,
              items: [
                {
                  name: "Building",
                  position: 1,
                  items: [
                    {
                      name: "Screws",
                      unit: "ENS",
                      position: 1,
                      unit_price_cents: 1500,
                      quantity: 4
                    },
                    {
                      name: "Bolts",
                      unit: "ENS",
                      position: 2,
                      unit_price_cents: 2000,
                      quantity: 8
                    }
                  ]
                }
              ]
            }
          end

          let!(:number_of_project_before) { Organization::Project.count }
          let!(:number_of_project_version_before) { Organization::ProjectVersion.count }
          let!(:number_of_items_before) { Organization::Item.count }
          let!(:number_of_item_groups_before) { Organization::ItemGroup.count }

          run_test! "create a new project with the relevant descendants" do
            expect(Organization::Project.count).to eq(number_of_project_before + 1)
            expect(Organization::ProjectVersion.count).to eq(number_of_project_version_before + 1)
            expect(Organization::Item.count).to eq(number_of_items_before + 2)
            expect(Organization::ItemGroup.count).to eq(number_of_item_groups_before + 1)
          end
        end
      end
    end
  end
end
