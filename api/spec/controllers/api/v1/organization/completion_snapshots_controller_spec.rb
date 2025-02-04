require "rails_helper"
require_relative "shared_examples/an_authenticated_endpoint"
require "swagger_helper"

RSpec.describe Api::V1::Organization::CompletionSnapshotsController, type: :request do
  path "/api/v1/organization/companies/{company_id}/projects/{project_id}/completion_snapshots" do
    post "Create a new completion snapshot on the project's last version" do
      tags "Completion snapshot"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :project_id, in: :path, type: :integer
      parameter name: :completion_snapshot, in: :body, schema: Organization::CreateCompletionSnapshotDto.to_schema()

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
      let(:completion_snapshot) {
        { description: "New version following discussion with the boss", completion_snapshot_items: [
          {
            item_id: company_project_version_item_group.grouped_items.first.id,
            completion_percentage: "10"
          }
        ] }
      }

      response "200", "completion snapshot successfully created" do
        schema Organization::ShowCompletionSnapshotResponseDto.to_schema
        context "when the project correctly belong to the company and there is no already existing draft" do
          let!(:number_of_completion_snapshot_before) { Organization::CompletionSnapshot.count }
          let!(:number_of_completion_snapshot_items_before) { Organization::CompletionSnapshotItem.count }

          run_test!("It creates a new completion snapshot with its items and returns it") {
            parsed_response = JSON.parse(response.body)
            new_snapshot = company_project_version.completion_snapshots.last
            expect(parsed_response.dig("result", "id")).to eq(new_snapshot.id)
            expect(Organization::CompletionSnapshot.count).to eq(number_of_completion_snapshot_before + 1)
            expect(Organization::CompletionSnapshotItem.count).to eq(number_of_completion_snapshot_items_before + 1)
          }
        end
      end

      response "422", "unprocessable entity" do
        context "when an draft already exists for this project" do
          let!(:already_existing_completion_snapshot) {
            FactoryBot.create("completion_snapshot", { project_version: company_project_version, description: "New version following discussion with the boss", completion_snapshot_items_attributes: [
              {
                item_id: company_project_version_item_group.grouped_items.first.id,
                completion_percentage: "10"
              }
            ] })
          }

          run_test!("It returns a 422 error with an explicit message") {
            parsed_response = JSON.parse(response.body)

            expect(parsed_response.dig("error", "message")).to eq("A draft already exists for this project. Only one draft can exists for a project at a time.")
          }
        end

        context "when the item_id does not belong to the project version" do
          let(:completion_snapshot) {
            { description: "New version following discussion with the boss", completion_snapshot_items: [
              {
                item_id: 99999999999,
                completion_percentage: "10"
              }
            ] }
          }

          run_test!("It returns a 422 error with an explicit message") {
            parsed_response = JSON.parse(response.body)

            expect(parsed_response.dig("error", "message")).to eq("The following item IDs do not belong to this project's last version: 99999999999")
          }
        end
      end

      response "401", "unauthorised" do
        context "when the user does not belong to the company" do
          let(:another_user) { FactoryBot.create(:user) }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(another_user.id)}" }

          run_test!
        end

        context "when the project_id does not belong to the company" do
          let(:project_id) { another_company_project.id }

          run_test!
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end

  path '/api/v1/organization/completion_snapshots/{id}' do
    parameter name: :id, in: :path, type: :integer

    get "Show completion snapshot details" do
      tags "Completion snapshot"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"

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
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:project_id) { company_project.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let!(:completion_snapshot) {
        FactoryBot.create("completion_snapshot", { project_version: company_project_version, description: "New version following discussion with the boss", completion_snapshot_items_attributes: [
          {
            item_id: company_project_version_item_group.grouped_items.first.id,
            completion_percentage: "10"
          }
        ] })
      }
      let(:id) { completion_snapshot.id }

      response "200", "show completion_snapshot" do
        schema Organization::ShowCompletionSnapshotResponseDto.to_schema

        run_test!
      end

      response "404", "not found" do
        context "when snapshot does not belong to a company of wich the user is a member" do
          let(:another_user) { FactoryBot.create(:user) }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(another_user.id)}" }

          run_test!
        end

        context "when the snapshot does not exists" do
          let(:id) { 123451234 }

          run_test!
        end
      end
    end
  end

  path '/api/v1/organization/completion_snapshots' do
    get "List all project version completion snapshot" do
      parameter name: :filter, in: :query, schema: Organization::CompletionSnapshotIndexRequestDto.to_schema
      parameter name: :query, in: :query, schema: QueryParamsDto.to_schema

      tags "Completion snapshot"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"

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
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:project_id) { company_project.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let!(:completion_snapshot) {
        FactoryBot.create("completion_snapshot", { project_version: company_project_version, description: "New version following discussion with the boss", completion_snapshot_items_attributes: [
          {
            item_id: company_project_version_item_group.grouped_items.first.id,
            completion_percentage: "10"
          }
        ] })
      }
      let!(:another_completion_snapshot) {
        FactoryBot.create("completion_snapshot", { project_version: company_project_version, description: "Another new version following discussion with the boss", completion_snapshot_items_attributes: [
          {
            item_id: company_project_version_item_group.grouped_items.first.id,
            completion_percentage: "10"
          }
        ] })
      }
      let(:filter) { {} }
      let(:query) { {} }

      response "200", "list completion_snapshot" do
        schema Organization::CompletionSnapshots::IndexDto.to_schema

        context "when no params are given" do
          run_test! "It returns all completion_snapshots of the companies of wich the user is a member"
        end

        context "when filter params are provide" do
          describe "company_id" do
            before do
              another_company = FactoryBot.create(:company, name: "AnotherCompany")
              another_client = FactoryBot.create(:client, company: another_company)
              another_project = FactoryBot.create(:project, client: another_client)
              another_project_version = FactoryBot.create(:project_version, project: another_project)
              another_project_version_item_group = FactoryBot.create(:item_group, project_version: another_project_version, name: "Item Group", grouped_items_attributes: [ {
                name: "Item",
                unit: "U",
                position: 1,
                unit_price_cents: "1000",
                project_version: company_project_version,
                quantity: 2
              } ])
              FactoryBot.create(:completion_snapshot, { project_version: another_project_version, description: "First completion snapshot for the project", completion_snapshot_items_attributes: [
                {
                  item_id: another_project_version_item_group.grouped_items.first.id,
                  completion_percentage: "10"
                }
              ] })

              FactoryBot.create(:member, user:, company: another_company)
            end

            let(:filter) { { filter: { company_id: Organization::Company.find_by({ name: "AnotherCompany" }).id } } }

            run_test!("It only returns the completion snapshots that belongs to the company") {
              parsed_response = JSON.parse(response.body)

              expect(parsed_response.dig("results", 0, "description")).to eq("First completion snapshot for the project")
              expect(parsed_response.dig("results").length).to eq(1)
            }
          end

          describe "project_id" do
            before do
              another_project = FactoryBot.create(:project, client: client, name: "AnotherProject")
              another_project_version = FactoryBot.create(:project_version, project: another_project)
              another_project_version_item_group = FactoryBot.create(:item_group, project_version: another_project_version, name: "Item Group", grouped_items_attributes: [ {
                name: "Item",
                unit: "U",
                position: 1,
                unit_price_cents: "1000",
                project_version: company_project_version,
                quantity: 2
              } ])
              FactoryBot.create(:completion_snapshot, { project_version: another_project_version, description: "First completion snapshot for the other project", completion_snapshot_items_attributes: [
                {
                  item_id: another_project_version_item_group.grouped_items.first.id,
                  completion_percentage: "10"
                }
              ] })
            end

            let(:filter) { { filter: { project_id: Organization::Project.find_by({ name: "AnotherProject" }).id } } }

            run_test!("It only returns the completion snapshots that belongs to project") {
              parsed_response = JSON.parse(response.body)

              expect(parsed_response.dig("results", 0, "description")).to eq("First completion snapshot for the other project")
              expect(parsed_response.dig("results").length).to eq(1)
            }
          end

          describe "project_version_id" do
            before do
              another_project_version = FactoryBot.create(:project_version, project: company_project)
              another_project_version_item_group = FactoryBot.create(:item_group, project_version: another_project_version, name: "Item Group", grouped_items_attributes: [ {
                name: "Item",
                unit: "U",
                position: 1,
                unit_price_cents: "1000",
                project_version: company_project_version,
                quantity: 2
              } ])
              FactoryBot.create(:completion_snapshot, { project_version: another_project_version, description: "First completion snapshot for the new version", completion_snapshot_items_attributes: [
                {
                  item_id: another_project_version_item_group.grouped_items.first.id,
                  completion_percentage: "10"
                }
              ] })
            end

            let(:filter) { { filter: { project_version_id: Organization::ProjectVersion.find_by({ project_id: company_project.id, number: 2 }).id } } }

            run_test!("It only returns the completion snapshots that belongs to project") {
              parsed_response = JSON.parse(response.body)

              expect(parsed_response.dig("results", 0, "description")).to eq("First completion snapshot for the new version")
              expect(parsed_response.dig("results").length).to eq(1)
            }
          end
        end

        context "when query params are provided" do
          describe "limit" do
            let(:query) { { query: { limit: 1 } } }

            run_test! "It limits the number of records returned" do
              parsed_response = JSON.parse(response.body)

              expect(parsed_response.dig("results").length).to eq(1)
            end
          end
        end
      end
    end
  end
end
