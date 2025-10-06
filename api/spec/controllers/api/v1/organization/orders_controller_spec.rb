require "rails_helper"
require "swagger_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"
require_relative "shared_examples/an_authenticated_endpoint"
require 'support/shared_contexts/organization/a_company_with_a_client_and_a_member'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

module Api
  module V1
    module Organization
      RSpec.describe OrdersController, type: :request do
        define_negated_matcher :not_change, :change
        path "/api/v1/organization/companies/{company_id}/orders" do
          get "List all the company's quotes" do
            tags "Orders"
            security [ bearerAuth: [] ]
            consumes "application/json"
            produces "application/json"
            parameter name: :company_id, in: :path, type: :integer

            let(:user) { FactoryBot.create(:user) }
            let!(:member) { FactoryBot.create(:member, user:, company:) }

            include_context 'a company with a project with three item groups'

            let(:company_id) { company.id }
            let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
            let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

            response "200", "list company's orders" do
              schema ::Organization::Projects::Orders::IndexDto.to_schema
              run_test! {
                parsed_response = JSON.parse(response.body)
                expect(parsed_response["results"].length).to eq(1)
                expect(parsed_response.dig("results", 0, "id")).to eq(project.id)
              }

              context "when the user is not a member of the company" do
                let(:another_user) { FactoryBot.create(:user) }
                let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(another_user.id)}" }

                run_test!("It returns an empty array") {
                  parsed_response = JSON.parse(response.body)
                  expect(parsed_response["results"].length).to eq(0)
                }
              end

              context "when the company does not exists" do
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

        path "/api/v1/organization/orders/{id}" do
          get "Show order details" do
            tags "Orders"
            security [ bearerAuth: [] ]
            produces "application/json"
            parameter name: :id, in: :path, type: :integer

            let(:user) { FactoryBot.create(:user) }
            let!(:member) { FactoryBot.create(:member, user:, company:) }

            include_context 'a company with a project with three item groups'

            let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
            let(:id) { project.id }

            response "200", "show order details" do
              schema ::Organization::Projects::Orders::ShowDto.to_schema
              run_test! {
                parsed_response = JSON.parse(response.body)
                expect(parsed_response.dig("result", "id")).to eq(project.id)
              }
            end

            response "404", "order not found" do
              context "when the user is not a member of the company" do
                let(:another_user) { FactoryBot.create(:user) }
                let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(another_user.id)}" }

                run_test!
              end

              context "when the order does not exist" do
                let(:id) { 123123123123123123123123 }
                let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

                run_test!
              end
            end
          end
          put "Update order" do
            tags "Orders"
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
                po_number: { type: :string },
                address_street: { type: :string },
                address_city: { type: :string },
                address_zipcode: { type: :string },
                retention_guarantee_rate: { type: :number },
                bank_detail_id: { type: :number },
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
                  po_number: "PO123456",
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

            let(:draft_order) {
              ::Organization::Quotes::ConvertToDraftOrder.call(quote.id).data
            }

            let!(:order) {
              ::Organization::DraftOrders::ConvertToOrder.call(draft_order.id).data
            }

            let(:id) { order.id }
            let(:body) { valid_body }
            let(:valid_body) do
              {
                name: "Updated Order",
                description: "Updated Description of the new order",
                po_number: "PO123456_UPDATED",
                address_street: "10 Rue de la mise à jour",
                retention_guarantee_rate: 0.05,
                bank_detail_id: company.bank_details.last.id,
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

            let(:first_version_first_item) { order.versions.first.items.find_by(name: "Item 1") }

            response "200", "order updated" do
              schema ::Organization::Projects::Orders::ShowDto.to_schema
              it "Updates the order by updating updatable attributes and by creating a new version", :aggregate_failures do |example|
                expect { submit_request(example.metadata) }
                  .to not_change(::Organization::Order, :count)
                  .and change(::Organization::ProjectVersion, :count).by(1)
                  .and change(::Organization::Item, :count).by(2)

                assert_response_matches_metadata(example.metadata)

                expect(JSON.parse(response.body).dig("result", "po_number")).to eq("PO123456_UPDATED")
                expect(JSON.parse(response.body).dig("result", "address_street")).to eq("10 Rue de la mise à jour")
              end

              context "when there is updated items" do
                run_test!("creates new item record but take the name, description and unit from the original record") {
                  new_version_first_item = order.last_version.items.find_by(original_item_uuid: first_version_first_item.original_item_uuid)
                  expect(new_version_first_item.name).to eq("Item 1")
                  expect(new_version_first_item.description).to eq("First item")
                  expect(new_version_first_item.unit).to eq("unit")
                }
              end
            end

            response "404", "order not found" do
              context "when the order does not exist" do
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
                      description: "Updated Description of the new order",
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
              end
            end
          end
        end

        path "/api/v1/organization/orders/{id}/invoiced_items" do
          get "invoiced amount for each item" do
            tags "Orders"
            security [ bearerAuth: [] ]
            consumes "application/json"
            produces "application/json"
            parameter name: :id, in: :path, type: :integer

            include_context 'a company with an order'

            let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
            let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
            let(:user) { FactoryBot.create(:user) }

            let(:id) { order.id }

            response "200", "ok" do
              schema ::Organization::Projects::InvoicedItemsDto.to_schema
              before {
                FactoryBot.create(:member, company:, user:)
              }

              context "when there is no previous invoices or credit notes" do
                let(:expected) do
                  {
                    "results" => [
                      {
                        "original_item_uuid" => order_version.items.first.original_item_uuid,
                        "invoiced_amount" => "0.0"
                      },
                      {
                        "original_item_uuid" => order_version.items.second.original_item_uuid,
                        "invoiced_amount" => "0.0"
                      },
                      {
                        "original_item_uuid" => order_version.items.third.original_item_uuid,
                        "invoiced_amount" => "0.0"
                      }
                    ].sort_by { |a| a["original_item_uuid"] }
                  }
                end

                run_test!("It returns 0 for each items") do
                  parsed_body = JSON.parse(response.body)

                  expect(parsed_body).to eq(expected)
                end
              end

              context "when there is some previous invoices or credit notes" do
                context "when those transaction are before the requested issue date (current time by default)" do
                  let(:expected) do
                    {
                      "results" => [
                        {
                          "original_item_uuid" => order_version.items.first.original_item_uuid,
                          "invoiced_amount" => "0.2"
                        },
                        {
                          "original_item_uuid" => order_version.items.second.original_item_uuid,
                          "invoiced_amount" => "0.0"
                        },
                        {
                          "original_item_uuid" => order_version.items.third.original_item_uuid,
                          "invoiced_amount" => "0.0"
                        }
                      ].sort_by { |a| a["original_item_uuid"] }
                    }
                  end

                  before {
                    proforma = ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data
                    ::Accounting::Proformas::Post.call(proforma.id)
                  }

                  run_test!("It returns the relevant amount for each items") do
                    parsed_body = JSON.parse(response.body)

                    expect(parsed_body).to eq(expected)
                  end
                end

                context "when those transaction are after the requested issue date (current time by default)" do
                  let(:expected) do
                    {
                      "results" => [
                        {
                          "original_item_uuid" => order_version.items.first.original_item_uuid,
                          "invoiced_amount" => "0.0"
                        },
                        {
                          "original_item_uuid" => order_version.items.second.original_item_uuid,
                          "invoiced_amount" => "0.0"
                        },
                        {
                          "original_item_uuid" => order_version.items.third.original_item_uuid,
                          "invoiced_amount" => "0.0"
                        }
                      ].sort_by { |a| a["original_item_uuid"] }
                    }
                  end

                  before {
                    proforma = ::Organization::Proformas::Create.call(order_version.id, { invoice_amounts: [ { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: "0.2" } ] }).data
                    ::Accounting::Proformas::Post.call(proforma.id, Time.current + 2.days)
                  }

                  run_test!("It does not take those transactions into account") do
                    parsed_body = JSON.parse(response.body)

                    expect(parsed_body).to eq(expected)
                  end
                end
              end
            end

            response "404", "not_found" do
              context "when the user is not a member of the order's company" do
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
