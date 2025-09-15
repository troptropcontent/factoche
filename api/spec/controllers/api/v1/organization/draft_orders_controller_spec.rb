require "rails_helper"
require "swagger_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"
require_relative "shared_examples/an_authenticated_endpoint"
require 'support/shared_contexts/organization/a_company_with_a_client_and_a_member'
require 'support/shared_contexts/organization/projects/a_company_with_a_draft_order'

module Api
  module V1
    module Organization
      RSpec.describe DraftOrdersController, type: :request do
        define_negated_matcher :not_change, :change
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
          put "Update draft order" do
            tags "Draft Orders"
            security [ bearerAuth: [] ]
            produces "application/json"
            security [ bearerAuth: [] ]
            consumes "application/json"
            produces "application/json"
            parameter name: :id, in: :path, type: :integer
            parameter name: :body, in: :body, schema: {
              type: :object,
              properties: {
                name: { type: :string },
                description: { type: :string },
                retention_guarantee_rate: { type: :number },
                new_items: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      group_uuid: { type: :string },
                      name: { type: :string },
                      description: { type: :string },
                      quantity: { type: :integer },
                      unit: { type: :string },
                      unit_price_amount: { type: :number },
                      position: { type: :integer },
                      tax_rate: { type: :number }
                    },
                    required: [ "name", "quantity", "unit", "unit_price_amount", "position", "tax_rate" ]
                  }
                },
                updated_items: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      group_uuid: { type: :string },
                      quantity: { type: :integer },
                      unit_price_amount: { type: :number },
                      position: { type: :integer },
                      tax_rate: { type: :number }
                    },
                    required: [ "quantity", "unit_price_amount", "position", "tax_rate" ]
                  }
                },
                groups: {
                  type: :array,
                  items: {
                    type: :object,
                    properties: {
                      uuid: { type: :string },
                      name: { type: :string },
                      description: { type: :string },
                      position: { type: :integer }
                    },
                    required: [ "uuid", "name", "position" ]
                  }
                }
              },
              required: [ "name", "retention_guarantee_rate", "items" ]
            }

            include_context 'a company with a client and a member'

            let(:Authorization) { access_token(user) }

            let(:quote) do
              ::Organization::Quotes::Create.call(
                company.id,
                client.id,
                company.bank_details.last.id,
                {
                  name: "Quote",
                  description: "Quote description",
                  retention_guarantee_rate: 0.05,
                  address_street: "10 Rue de la Paix",
                  address_zipcode: "75002",
                  address_city: "Paris",
                  groups: [
                    { uuid: "group-1", name: "Group 1", description: "First group", position: 0 }
                  ],
                  items: [
                    {
                      group_uuid: "group-1",
                      name: "Item 1",
                      description: "First item",
                      position: 1,
                      unit: "unit",
                      unit_price_amount: 100.0,
                      quantity: 1,
                      tax_rate: 0.2
                    }
                  ]
                }
              ).data
            end

            let!(:draft_order) {
              ::Organization::Quotes::ConvertToDraftOrder.call(quote.id).data
            }
            let(:id) { draft_order.id }
            let(:body) { valid_body }
            let(:valid_body) do
              {
                name: "Updated Draft Order",
                description: "Updated Description of the new draft order",
                retention_guarantee_rate: 0.05,
                groups: [
                  { uuid: "group-1", name: "Group 1", description: "First group", position: 0 }
                ],
                new_items: [
                  {
                    group_uuid: "group-1",
                    name: "Item 2",
                    description: "Second item",
                    position: 1,
                    unit: "unit",
                    unit_price_amount: 100.0,
                    quantity: 1,
                    tax_rate: 0.2
                  }
                ],
                updated_items: [
                  {
                    original_item_uuid: first_version_first_item.original_item_uuid,
                    group_uuid: "group-1",
                    position: 2,
                    unit_price_amount: 100.0,
                    quantity: 1,
                    tax_rate: 0.2
                  }
                ]
              }
            end

            let(:first_version_first_item) { draft_order.versions.first.items.find_by(name: "Item 1") }

            response "200", "draft order updated" do
              schema ::Organization::Projects::DraftOrders::ShowDto.to_schema
              it "Updates the draft order by updating updatable attributes and by creating a new version", :aggregate_failures do |example|
                expect { submit_request(example.metadata) }
                  .to not_change(::Organization::DraftOrder, :count)
                  .and change(::Organization::ProjectVersion, :count).by(1)
                  .and change(::Organization::Item, :count).by(2)

                assert_response_matches_metadata(example.metadata)
              end

              context "when there is updated items" do
                run_test!("creates new item record but take the name, description and unit from the original record") {
                  new_version_first_item = draft_order.last_version.items.find_by(original_item_uuid: first_version_first_item.original_item_uuid)
                  expect(new_version_first_item.name).to eq("Item 1")
                  expect(new_version_first_item.description).to eq("First item")
                  expect(new_version_first_item.unit).to eq("unit")
                }
              end
            end

            response "404", "draft order not found" do
              context "when the draft order does not exist" do
                let(:id) { -1 }
                let(:Authorization) { access_token(user) }

                run_test!
              end
            end

            response "401", "unauthorized" do
              context "when the user is not a member of the company" do
                let(:another_user) { FactoryBot.create(:user) }
                let(:Authorization) { access_token(another_user) }

                run_test!
              end
            end

            response "422", "unprocessable entity" do
              context "when the params are not valid" do
                context "when a required key is missing" do
                  let(:body) { body_without_name }
                  let(:body_without_name) do
                    {
                      description: "Updated Description of the new draft order",
                      retention_guarantee_rate: 0.05,
                      groups: [
                        { uuid: "group-1", name: "Group 1", description: "First group", position: 0 }
                      ],
                      new_items: [
                        {
                          group_uuid: "group-1",
                          name: "Item 2",
                          description: "Second item",
                          position: 1,
                          unit: "unit",
                          unit_price_amount: 100.0,
                          quantity: 1,
                          tax_rate: 0.2
                        }
                      ],
                      updated_items: [
                        {
                          original_item_uuid: first_version_first_item.original_item_uuid,
                          group_uuid: "group-1",
                          position: 2,
                          unit_price_amount: 100.0,
                          quantity: 1,
                          tax_rate: 0.2
                        }
                      ]
                    }
                  end

                  run_test!
                end

                context "when an item reference a group that is not provided" do
                  let(:body) { body_with_wrong_group_uuid_amoung_items }
                  let(:body_with_wrong_group_uuid_amoung_items) {
                    valid_body.merge({
                      updated_items: [
                        valid_body.dig(:updated_items, 0).merge({
                          group_uuid: "a-uuid-that-is-not-valid"
                        })
                      ]
                    })
                  }

                  run_test!
                end

                context "when a group is not referenced by at least one item" do
                  let(:body) { body_with_group_uuid_not_referenced_amoung_items }
                  let(:body_with_group_uuid_not_referenced_amoung_items) {
                    valid_body.merge({
                      groups: valid_body.dig(:groups).push({ uuid: "group-2", name: "Group 2", description: "Second group", position: 1 })
                    })
                  }

                  run_test!
                end

                context "when the draft order is already posted" do
                  before {
                    ::Organization::DraftOrders::ConvertToOrder.call(draft_order.id)
                  }

                  run_test!
                end
              end
            end
          end
        end

        path "/api/v1/organization/draft_orders/{id}/convert_to_order" do
          post "Convert a draft order to an order" do
            tags "Draft Orders"
            security [ bearerAuth: [] ]
            consumes "application/json"
            produces "application/json"
            parameter name: :id, in: :path, type: :integer

            let(:user) { FactoryBot.create(:user) }
            let!(:member) { FactoryBot.create(:member, user:, company:) }
            let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

            let(:id) { draft_order.id }

            include_context 'a company with a draft order'

            response "200", "draft order converted to order" do
              schema ::Organization::Projects::Orders::ShowDto.to_schema
              before { draft_order }

              it "create a new order based on the draft_order", :aggregate_failures do |example|
                expect { submit_request(example.metadata) }
                  .to not_change(::Organization::DraftOrder, :count)
                  .and change(::Organization::Order, :count).by(1)
                  .and change(::Organization::ProjectVersion, :count).by(1)
                  .and change(::Organization::Item, :count).by(3)

                assert_response_matches_metadata(example.metadata)
              end
            end

            response "404", "draft order not found" do
              let(:id) { -1 }

              run_test! do
                expect(response.body).to include("Resource not found")
              end
            end

            response "401", "unauthorized" do
              let(:id) { draft_order.id }
              let(:another_user) { FactoryBot.create(:user) }
              let(:Authorization) { access_token(another_user) }

              run_test!
            end

            response "422", "unprocessable entity" do
              context "when the draft order has already been converted" do
                before { ::Organization::DraftOrders::ConvertToOrder.call(draft_order.id) }

                run_test! do
                  expect(response.body).to include("Draft order has already been converted to an order")
                end
              end
            end

            it_behaves_like "an authenticated endpoint"
          end
        end
      end
    end
  end
end
