require "rails_helper"
require_relative "shared_examples/an_authenticated_endpoint"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"
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
      parameter name: :completion_snapshot, in: :body, schema: Organization::CreateCompletionSnapshotDto.to_schema

      let(:user) { FactoryBot.create(:user) }
      include_context 'a company with a project with three item groups'

      let(:another_company) { FactoryBot.create(:company) }
      let(:another_client) { FactoryBot.create(:client, company: another_company) }
      let!(:another_company_project) { FactoryBot.create(:project, client: another_client) }
      let!(:member) { FactoryBot.create(:member, user: user, company: company) }
      let(:company_id) { company.id }
      let(:project_id) { project.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let(:completion_snapshot) do
        {
          description: "New version following discussion with the boss",
          completion_snapshot_items: [ {
            item_id: project_version_first_item_group_item.id,
            completion_percentage: "0.10"
          } ]
        }
      end

      response "200", "completion snapshot successfully created" do
        schema Organization::CompletionSnapshots::ShowDto.to_schema
        context "when the project correctly belong to the company and there is no already existing draft" do
          let!(:number_of_completion_snapshot_before) { Organization::CompletionSnapshot.count }
          let!(:number_of_completion_snapshot_items_before) { Organization::CompletionSnapshotItem.count }

          run_test!("It creates a new completion snapshot with its items and returns it") do
            parsed_response = JSON.parse(response.body)
            new_snapshot = project_version.completion_snapshots.last
            expect(parsed_response.dig("result", "id")).to eq(new_snapshot.id)
            expect(Organization::CompletionSnapshot.count).to eq(number_of_completion_snapshot_before + 1)
            expect(Organization::CompletionSnapshotItem.count).to eq(number_of_completion_snapshot_items_before + 1)
          end
        end
      end

      response "422", "unprocessable entity" do
        context "when an draft already exists for this project" do
          let!(:already_existing_completion_snapshot) do
            s = FactoryBot.create(
              "completion_snapshot",
              "with_invoice",
              {
                project_version: project_version,
                description: "New version following discussion with the boss",
                completion_snapshot_items_attributes: [ {
                  item_id: project_version_first_item_group_item.id,
                  completion_percentage: "0.10"
                } ]
              }
            )
          end

          run_test!("It returns a 422 error with an explicit message") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("error", "message")).to eq("A draft already exists for this project. Only one draft can exists for a project at a time.")
          end
        end

        context "when the item_id does not belong to the project version" do
          let(:completion_snapshot) do
            {
              description: "New version following discussion with the boss",
              completion_snapshot_items: [ {
                item_id: 99999999999,
                completion_percentage: "0.10"
              } ]
            }
          end

          run_test!("It returns a 422 error with an explicit message") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("error", "message")).to eq("The following item IDs do not belong to this project's last version: 99999999999")
          end
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
      let(:company) { FactoryBot.create(:company, :with_config) }
      let(:client) { FactoryBot.create(:client, company: company) }
      let(:company_project) { FactoryBot.create(:project, client: client) }
      let(:company_project_version) { FactoryBot.create(:project_version, project: company_project) }
      let!(:company_project_version_item_group) do
        FactoryBot.create(
          :item_group,
          project_version: company_project_version,
          name: "Item Group",
          grouped_items_attributes: [ {
            original_item_uuid: SecureRandom.uuid,
            name: "Item",
            unit: "U",
            position: 1,
            unit_price_cents: "1000",
            project_version: company_project_version,
            quantity: 2
          } ]
        )
      end
      let!(:member) { FactoryBot.create(:member, user: user, company: company) }
      let(:company_id) { company.id }
      let(:project_id) { company_project.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let!(:completion_snapshot) do
        FactoryBot.create(
          "completion_snapshot",
          :with_invoice,
          {
            project_version: company_project_version,
            description: "New version following discussion with the boss",
            completion_snapshot_items_attributes: [ {
              item_id: company_project_version_item_group.grouped_items.first.id,
              completion_percentage: "0.10"
            } ]
          }
        )
      end
      let(:id) { completion_snapshot.id }

      response "200", "show completion_snapshot" do
        schema Organization::CompletionSnapshots::ShowDto.to_schema

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

    put "Update completion snapshot" do
      tags "Completion snapshot"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer
      parameter name: :payload, in: :body, schema: Organization::CompletionSnapshots::UpdateDto.to_schema

      let(:user) { FactoryBot.create(:user) }
      include_context 'a company with a project with three item groups'
      let(:completion_snapshot) do
        FactoryBot.create(
          :completion_snapshot,
          :with_invoice,
          {
            project_version: project_version,
            description: "First snapshot",
            completion_snapshot_items_attributes: [ {
              item_id: project_version_first_item_group_item.id,
              completion_percentage: "0.10"
            } ]
          }
        )
      end
      let(:id) { completion_snapshot.id }
      let(:payload) {
          {
            completion_snapshot_items: [ {
              item_id: project_version_first_item_group_item.id,
              completion_percentage: "0.20"
            } ]
          }
      }

      it_behaves_like "an authenticated endpoint"

      response "200", "updates completion snapshot" do
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        before { FactoryBot.create(:member, company:, user:) }

        schema Organization::CompletionSnapshots::ShowDto.to_schema

        run_test!("updates the completion snapshot and returns the updated record") do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response.dig("result", "completion_snapshot_items", 0, "completion_percentage")).to eq("0.2")
        end
      end

      response "422", "unprocessable entity" do
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        before {
          FactoryBot.create(:member, company:, user:)
        }

        context "when the completion snapshot is not in draft status" do
          before {
            completion_snapshot.invoice.update(status: :published)
          }

          run_test!("returns a 422 with an explicit message") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("error", "message")).to eq("Cannot update completion snapshot with status 'published'. Only snapshots in 'draft' status can be updated")
          end

          run_test!("does not update the record") do
            expect(completion_snapshot.completion_snapshot_items.first.completion_percentage).to eq(BigDecimal("0.10"))
          end
        end

        context "when an item ID does not belong to the project version" do
          let(:payload) { {
            completion_snapshot_items: [ {
              item_id: 99999999,
              completion_percentage: "0.20"
            } ]
          }}

          run_test!("returns a 422 with an explicit message") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("error", "message")).to eq("The following item IDs do not belong to this completion snapshot project version: 99999999")
          end

          run_test!("does not update the record") do
            expect(completion_snapshot.completion_snapshot_items.first.completion_percentage).to eq(BigDecimal("0.10"))
          end
        end
      end

      response "404", "not found" do
        context "when the completion snapshot does not exist" do
          let(:id) { 99999999 }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

          before { FactoryBot.create(:member, company:, user:) }

          run_test!
        end

        context "when the completion snapshot does not belong to a company of which the user is a member" do
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(FactoryBot.create(:user).id)}" }

          run_test!
        end
      end
    end

    delete "Delete completion snapshot" do
      tags "Completion snapshot"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      include_context 'a company with a project with three item groups'
      let(:completion_snapshot) do
        FactoryBot.create(
          :completion_snapshot,
          :with_invoice,
          {
            project_version: project_version,
            description: "First snapshot",
            completion_snapshot_items_attributes: [ {
              item_id: project_version_first_item_group_item.id,
              completion_percentage: "0.10"
            } ]
          }
        )
      end
      let(:id) { completion_snapshot.id }

      response "204", "no content" do
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        before { FactoryBot.create(:member, company:, user:) }

        run_test!("it destroys the record from the database") {
          expect { Organization::CompletionSnapshot.find(id) }.to raise_error(ActiveRecord::RecordNotFound)
        }
      end

      it_behaves_like "an authenticated endpoint"

      response "422", "unprocessable entity" do
        context "when the completion snapshot is not draft" do
          before { FactoryBot.create(:member, company:, user:) }

          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
          let(:completion_snapshot) do
            FactoryBot.create(
              :completion_snapshot,
              :with_invoice,
              {
                project_version: project_version,
                description: "First snapshot"
              }
            )
          end

          before { completion_snapshot.invoice.update(status: :published) }

          run_test!("it returns a 422 with an explicit message") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("error", "message")).to eq("Cannot delete completion snapshot with status 'published'. Only snapshots in 'draft' status can be deleted")
          end
        end
      end

      response "404", "not found" do
        context "when the completion snapshot does not exist" do
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
          let(:id) { 999999999999 }

          run_test!
        end

        context "when the completion snapshot does not belong to a company the user is a member of" do
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(FactoryBot.create(:user).id)}" }

          run_test!
        end
      end
    end
  end

  path '/api/v1/organization/completion_snapshots/{id}/previous' do
    parameter name: :id, in: :path, type: :integer

    get "Show previous completion snapshot details" do
      tags "Completion snapshot"
      security [ bearerAuth: [] ]
      produces "application/json"

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company, :with_config) }
      let(:client) { FactoryBot.create(:client, company: company) }
      let(:company_project) { FactoryBot.create(:project, client: client) }
      let(:company_project_version) { FactoryBot.create(:project_version, project: company_project) }
      let!(:company_project_version_item_group) do
        FactoryBot.create(
          :item_group,
          project_version: company_project_version,
          name: "Item Group",
          grouped_items_attributes: [ {
            original_item_uuid: SecureRandom.uuid,
            name: "Item",
            unit: "U",
            position: 1,
            unit_price_cents: "1000",
            project_version: company_project_version,
            quantity: 2
          } ]
        )
      end
      let!(:member) { FactoryBot.create(:member, user: user, company: company) }
      let(:company_id) { company.id }
      let(:project_id) { company_project.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let(:id) { Organization::CompletionSnapshot.last.id }

      response "200", "show previous completion_snapshot" do
        schema Organization::CompletionSnapshots::PreviousDto.to_schema

        context "when there is a previous completion snapshot" do
          before do
            travel_to(1.day.before) {
              FactoryBot.create(
              "completion_snapshot",
              :with_invoice,
              {
                project_version: company_project_version,
                description: "First snapshot",
                completion_snapshot_items_attributes: [ {
                  item_id: company_project_version_item_group.grouped_items.first.id,
                  completion_percentage: "0.10"
                } ]
              }
            ) }

            FactoryBot.create(
              "completion_snapshot",
              :with_invoice,
              {
                project_version: company_project_version,
                description: "Second snapshot",
                completion_snapshot_items_attributes: [ {
                  item_id: company_project_version_item_group.grouped_items.first.id,
                  completion_percentage: "0.20"
                } ]
              }
            )
          end

          run_test!("it returns the previous completion snapshot") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("result", "id")).to eq(Organization::CompletionSnapshot.first.id)
          end
        end

        context "when there is no previous completion snapshot" do
          before do
            FactoryBot.create(
              "completion_snapshot",
              :with_invoice,
              {
                project_version: company_project_version,
                description: "New version following discussion with the boss",
                completion_snapshot_items_attributes: [ {
                  item_id: company_project_version_item_group.grouped_items.first.id,
                  completion_percentage: "0.20"
                } ]
              }
            )
          end

          run_test!("it returns null") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("result")).to be_nil
          end
        end
      end

      response "404", "not found" do
        context "when snapshot does not belong to a company of wich the user is a member" do
          before do
            FactoryBot.create(
              "completion_snapshot",
              :with_invoice,
              {
                project_version: company_project_version,
                description: "New version following discussion with the boss",
                completion_snapshot_items_attributes: [ {
                  item_id: company_project_version_item_group.grouped_items.first.id,
                  completion_percentage: "0.20"
                } ]
              }
            )
          end

          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(FactoryBot.create(:user).id)}" }

          run_test!
        end

        context "when the snapshot does not exists" do
          let(:id) { 123451234 }

          run_test!
        end
      end
    end
  end

  path '/api/v1/organization/completion_snapshots/{id}/publish' do
    parameter name: :id, in: :path, type: :integer

    post "Publish the completion snapshot" do
      tags "Completion snapshot"
      security [ bearerAuth: [] ]
      produces "application/json"

      include_context 'a company with a project with three item groups'

      let(:project_version_first_item_group_item_quantity) { 1 }
      let(:project_version_first_item_group_item_unit_price_cents) { 1000 }
      let(:project_version_second_item_group_item_quantity) { 2 }
      let(:project_version_second_item_group_item_unit_price_cents) { 2000 }
      let(:project_version_third_item_group_item_quantity) { 3 }
      let(:project_version_third_item_group_item_unit_price_cents) { 3000 }
      let(:snapshot) do
        FactoryBot.create(
          :completion_snapshot,
          :with_invoice,
          project_version: project_version,
          completion_snapshot_items_attributes: [
            {
              item_id: project_version_first_item_group_item.id,
              completion_percentage: BigDecimal("0.05")
            },
            {
              item_id: project_version_second_item_group_item.id,
              completion_percentage: BigDecimal("0.10")
            },
            {
              item_id: project_version_third_item_group_item.id,
              completion_percentage: BigDecimal("0.15")
            }
          ]
        )
      end

      let(:user) { FactoryBot.create(:user) }
      before do
        FactoryBot.create(:member, user: user, company: company)
      end

      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let(:id) { snapshot.id }

      response "200", "completion snapshot published" do
        schema Organization::CompletionSnapshots::ShowDto.to_schema

        context "when the snapshot is in draft mode" do
          let!(:number_of_invoices_before) { Organization::CompletionSnapshot.count() }

          run_test!("it creates a new invoice and switch the snapshot to :invoiced") do
            parsed_response = JSON.parse(response.body)
            expect(Organization::CompletionSnapshot.count()).to eq(number_of_invoices_before + 1)
            expect(parsed_response.dig("result", "status")).to eq("published")
          end
        end
      end

      it_behaves_like "an authenticated endpoint"

      response "422", "unprocessable entity" do
        context "when the completion snapshot is not in draft status" do
          let(:snapshot) do
            FactoryBot.create(
              :completion_snapshot,
              :with_invoice,
              project_version: project_version,
            )
          end

          before {
            snapshot.invoice.update(status: :published)
          }

          run_test!("it returns a 422 with an explicit message") do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("error", "message")).to eq("Only draft completion snapshots can be transitioned to invoiced")
          end
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
      let(:company) { FactoryBot.create(:company, :with_config) }
      let(:client) { FactoryBot.create(:client, company: company) }
      let(:company_project) { FactoryBot.create(:project, client: client) }
      let(:company_project_version) { FactoryBot.create(:project_version, project: company_project) }
      let!(:company_project_version_item_group) do
        FactoryBot.create(
          :item_group,
          project_version: company_project_version,
          name: "Item Group",
          grouped_items_attributes: [ {
            original_item_uuid: SecureRandom.uuid,
            name: "Item",
            unit: "U",
            position: 1,
            unit_price_cents: "1000",
            project_version: company_project_version,
            quantity: 2
          } ]
        )
      end
      let!(:member) { FactoryBot.create(:member, user: user, company: company) }
      let(:company_id) { company.id }
      let(:project_id) { company_project.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let!(:completion_snapshot) do
        snapshot = FactoryBot.create(
          "completion_snapshot",
          {
            project_version: company_project_version,
            description: "New version following discussion with the boss",
            completion_snapshot_items_attributes: [ {
              item_id: company_project_version_item_group.grouped_items.first.id,
              completion_percentage: "0.10"
            } ]
          }
        )
        FactoryBot.create(:invoice, completion_snapshot: snapshot)
        snapshot
      end
      let!(:another_completion_snapshot) do
        snapshot = FactoryBot.create(
          "completion_snapshot",
          {
            project_version: company_project_version,
            description: "Another new version following discussion with the boss",
            completion_snapshot_items_attributes: [ {
              item_id: company_project_version_item_group.grouped_items.first.id,
              completion_percentage: "0.10"
            } ]
          }
          )
          FactoryBot.create(:invoice, completion_snapshot: snapshot)
          snapshot
      end
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
              another_project_version_item_group = FactoryBot.create(
                :item_group,
                project_version: another_project_version,
                name: "Item Group",
                grouped_items_attributes: [ {
                  original_item_uuid: SecureRandom.uuid,
                  name: "Item",
                  unit: "U",
                  position: 1,
                  unit_price_cents: "1000",
                  project_version: company_project_version,
                  quantity: 2
                } ]
              )
              another_completion_snapshot = FactoryBot.create(
                :completion_snapshot,
                {
                  project_version: another_project_version,
                  description: "First completion snapshot for the project",
                  completion_snapshot_items_attributes: [ {
                    item_id: another_project_version_item_group.grouped_items.first.id,
                    completion_percentage: "0.10"
                  } ]
                }
              )
              FactoryBot.create(:invoice, completion_snapshot: another_completion_snapshot)

              FactoryBot.create(:member, user: user, company: another_company)
            end

            let(:filter) { { filter: { company_id: Organization::Company.find_by({ name: "AnotherCompany" }).id } } }

            run_test!("It only returns the completion snapshots that belongs to the company") do
              parsed_response = JSON.parse(response.body)

              expect(parsed_response.dig("results", 0, "description")).to eq("First completion snapshot for the project")
              expect(parsed_response.dig("results").length).to eq(1)
            end
          end

          describe "project_id" do
            before do
              another_project = FactoryBot.create(:project, client: client, name: "AnotherProject")
              another_project_version = FactoryBot.create(:project_version, project: another_project)
              another_project_version_item_group = FactoryBot.create(
                :item_group,
                project_version: another_project_version,
                name: "Item Group",
                grouped_items_attributes: [ {
                  original_item_uuid: SecureRandom.uuid,
                  name: "Item",
                  unit: "U",
                  position: 1,
                  unit_price_cents: "1000",
                  project_version: company_project_version,
                  quantity: 2
                } ]
              )
              another_completion_snapshot = FactoryBot.create(
                :completion_snapshot,
                {
                  project_version: another_project_version,
                  description: "First completion snapshot for the other project",
                  completion_snapshot_items_attributes: [ {
                    item_id: another_project_version_item_group.grouped_items.first.id,
                    completion_percentage: "0.10"
                  } ]
                }
              )
              FactoryBot.create(:invoice, completion_snapshot: another_completion_snapshot)
            end

            let(:filter) { { filter: { project_id: Organization::Project.find_by({ name: "AnotherProject" }).id } } }

            run_test!("It only returns the completion snapshots that belongs to project") do
              parsed_response = JSON.parse(response.body)

              expect(parsed_response.dig("results", 0, "description")).to eq("First completion snapshot for the other project")
              expect(parsed_response.dig("results").length).to eq(1)
            end
          end

          describe "project_version_id" do
            before do
              another_project_version = FactoryBot.create(:project_version, project: company_project)
              another_project_version_item_group = FactoryBot.create(
                :item_group,
                project_version: another_project_version,
                name: "Item Group",
                grouped_items_attributes: [ {
                  original_item_uuid: SecureRandom.uuid,
                  name: "Item",
                  unit: "U",
                  position: 1,
                  unit_price_cents: "1000",
                  project_version: company_project_version,
                  quantity: 2
                } ]
              )
              another_completion_snapshot = FactoryBot.create(
                :completion_snapshot,
                {
                  project_version: another_project_version,
                  description: "First completion snapshot for the new version",
                  completion_snapshot_items_attributes: [ {
                    item_id: another_project_version_item_group.grouped_items.first.id,
                    completion_percentage: "0.10"
                  } ]
                }
              )
              FactoryBot.create(:invoice, completion_snapshot: another_completion_snapshot)
            end

            let(:filter) { { filter: { project_version_id: Organization::ProjectVersion.find_by({ project_id: company_project.id, number: 2 }).id } } }

            run_test!("It only returns the completion snapshots that belongs to project") do
              parsed_response = JSON.parse(response.body)

              expect(parsed_response.dig("results", 0, "description")).to eq("First completion snapshot for the new version")
              expect(parsed_response.dig("results").length).to eq(1)
            end
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
