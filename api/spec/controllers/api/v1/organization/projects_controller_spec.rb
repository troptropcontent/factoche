require "rails_helper"
require "swagger_helper"

RSpec.describe Api::V1::Organization::ProjectsController, type: :request do
  path "/api/v1/organization/companies/{company_id}/projects" do
    post "Creates a new project and its descendants" do
      tags "Projects"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :project, in: :body, schema: Organization::CreateProjectDto.to_schema

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company) }
      let!(:client) { FactoryBot.create(:client, company: company) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      response "200", "project created" do
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

      response "404", "not found" do
        let(:project) { {} }
        describe "when the company does not exists" do
          let(:company_id) { "not_existing_id" }

          run_test!
        end
      end

      response "401", "not authorised" do
        describe "when the user is not a member of the company" do
          let(:another_company) { FactoryBot.create(:company) }
          let!(:company_id) { another_company.id }
          let(:project) { {} }

          run_test!
        end

        describe "when the client does not belong to the company" do
          let(:another_company) { FactoryBot.create(:company) }
          let!(:another_client_of_another_company) { FactoryBot.create(:client, company: another_company) }
          let(:project) { {
            client_id: another_client_of_another_company.id
          } }

          run_test!
        end
      end

      response "422", "unprocessable entity" do
        schema "$ref": "#/components/schemas/error"

        describe "when the project to create is not valid" do
          context "when the rentention_guarantee_rate is not valid" do
            let(:project) do
              {
                name: "Amazing Project",
                client_id: client.id,
                retention_guarantee_rate: 500000,
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

            run_test!
          end

          context "when the name is already taken" do
            let!(:already_created_project) { FactoryBot.create(:project, client: client, name: "Already Taken project") }

            let(:project) do
              {
                name: already_created_project.name,
                client_id: client.id,
                retention_guarantee_rate: 500,
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

            run_test!
          end

          context "when one item name is already taken by another" do
            let(:project) do
              {
                name: "Project with items that have the same name",
                client_id: client.id,
                retention_guarantee_rate: 500,
                items: [
                  {
                    name: "Screws",
                    unit: "ENS",
                    position: 1,
                    unit_price_cents: 1500,
                    quantity: 4
                  },
                  {
                    name: "Screws",
                    unit: "ENS",
                    position: 2,
                    unit_price_cents: 2000,
                    quantity: 8
                  }
                ]
              }
            end
          end
        end
      end
    end

    get "List all the company's project" do
      tags "Projects"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :company_id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company) }
      let(:client) { FactoryBot.create(:client, company: company) }
      let!(:company_project) { FactoryBot.create(:project, client: client,) }
      let(:another_company) { FactoryBot.create(:company) }
      let(:another_client) { FactoryBot.create(:client, company: another_company) }
      let!(:another_company_project) { FactoryBot.create(:project, client: another_client,) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      response "200", "list company's projects" do
        schema Organization::ProjectIndexResponseDto.to_schema
        run_test! {
          parsed_response = JSON.parse(response.body)
          expect(parsed_response["results"].length).to eq(1)
          expect(parsed_response.dig("results", 0, "id")).to eq(company_project.id)
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
      end
    end
  end

  path "/api/v1/organization/companies/{company_id}/projects/{id}" do
    get "Show the project details" do
      tags "Projects"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company) }
      let(:client) { FactoryBot.create(:client, company: company) }
      let(:company_project) { FactoryBot.create(:project, client: client) }
      let!(:company_project_version) { FactoryBot.create(:project_version, project: company_project) }
      let!(:company_project_version_item_group) { FactoryBot.create(:item_group, project_version: company_project_version, name: "Item Group", grouped_items_attributes: [ {
        name: "Item",
        unit: "U",
        position: 1,
        unit_price_cents: "1000",
        project_version: company_project_version,
        quantity: 2,
        original_item_uuid: SecureRandom.uuid
      } ]) }
      let(:another_company) { FactoryBot.create(:company) }
      let(:another_client) { FactoryBot.create(:client, company: another_company) }
      let!(:another_company_project) { FactoryBot.create(:project, client: another_client,) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:id) { company_project.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      response "200", "list company's projects" do
        schema Organization::ProjectShowResponseDto.to_schema
        run_test! {
          parsed_response = JSON.parse(response.body)

          expect(parsed_response.dig("result", "id")).to eq(company_project.id)
          expect(parsed_response.dig("result", "client", "id")).to eq(client.id)
          expect(parsed_response.dig("result", "last_version", "id")).to eq(company_project_version.id)
          expect(parsed_response.dig("result", "last_version", "item_groups", 0, "id")).to eq(company_project_version_item_group.id)
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

        context "when the project does not exists within the company" do
          let(:id) { 123123123123123123123123 }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

          run_test!
        end
      end
    end
  end
end
