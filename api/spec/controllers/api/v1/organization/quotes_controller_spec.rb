require "rails_helper"
require "swagger_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"
require 'support/shared_contexts/organization/a_company_with_a_client_and_a_member'
require_relative "shared_examples/an_authenticated_endpoint"
# rubocop:disable RSpec/ExampleLength
RSpec.describe Api::V1::Organization::QuotesController, type: :request do
  define_negated_matcher :not_change, :change
  path "/api/v1/organization/companies/{company_id}/quotes" do
    get "List all the company's quotes" do
      tags "Quotes"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :company_id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }

      include_context 'a company with a project with three item groups'

      let(:company_id) { company.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      response "200", "list company's projects" do
        schema Organization::Projects::Quotes::IndexDto.to_schema
        run_test! {
          parsed_response = JSON.parse(response.body)
          expect(parsed_response["results"].length).to eq(1)
          expect(parsed_response.dig("results", 0, "id")).to eq(quote.id)
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
  path "/api/v1/organization/quotes/{id}" do
    get "Show quote details" do
      tags "Quotes"
      security [ bearerAuth: [] ]
      produces "application/json"
      parameter name: :id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }

      include_context 'a company with a project with three item groups'

      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let(:id) { quote.id }

      response "200", "show quote details" do
        schema Organization::Projects::Quotes::ShowDto.to_schema
        run_test! {
          parsed_response = JSON.parse(response.body)
          expect(parsed_response.dig("result", "id")).to eq(quote.id)
        }
      end

      response "404", "quote not found" do
        context "when the quote does not exist" do
          let(:id) { 123123123123123123123123 }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

          run_test!
        end
      end

      response "401", "unauthorized" do
        context "when the user is not a member of the company" do
          let(:another_user) { FactoryBot.create(:user) }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(another_user.id)}" }

          run_test!
        end
      end
    end
    put "Update quote" do
      tags "Quotes"
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
          },
          new_discounts: {
            type: :array,
            items: {
              type: :object,
              properties: {
                name: { type: :string },
                kind: { type: :string, enum: [ "percentage", "fixed_amount" ] },
                value: { type: :number, format: :decimal },
                position: { type: :integer }
              },
              required: [ "name", "kind", "value", "position" ]
            }
          },
          updated_discounts: {
            type: :array,
            items: {
              type: :object,
              properties: {
                original_discount_uuid: { type: :string },
                kind: { type: :string, enum: [ "percentage", "fixed_amount" ] },
                value: { type: :number, format: :decimal },
                position: { type: :integer }
              },
              required: [ "kind", "original_discount_uuid", "value", "position" ]
            }
          }
        },
        required: [ "name", "retention_guarantee_rate", "new_items", "updated_items", "new_discounts", "updated_discounts" ]
      }

      include_context 'a company with a client and a member'

      let(:Authorization) { access_token(user) }

      let(:id) { quote.id }
      let!(:quote) do
        ::Organization::Quotes::Create.call(
          company.id,
          client.id,
          company.bank_details.last.id,
          {
            name: "Updated Quote",
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
              },
              {
                group_uuid: "group-1",
                name: "Item 2",
                position: 2,
                unit: "unit",
                unit_price_amount: 200.0,
                quantity: 2,
                tax_rate: 0.1
              }
            ]
          }
        ).data
      end
      let(:body) { valid_body }
      let(:valid_body) do
        {
          name: "Updated Quote",
          description: "Updated Description of the new quote",
          retention_guarantee_rate: 0.05,
          bank_detail_id: company.bank_details.last.id,
          po_number: "PO123456_UPDATED",
          address_street: "10 Rue de la mise à jour",
          address_zipcode: "75002",
          address_city: "Paris",
          groups: [
            { uuid: "group-1", name: "Group 1", description: "First group", position: 0 }
          ],
          new_items: [
            {
              group_uuid: "group-1",
              name: "Item 3",
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
            },
            {
              original_item_uuid: first_version_second_item.original_item_uuid,
              group_uuid: "group-1",
              position: 2,
              unit_price_amount: 300.0,
              quantity: 1,
              tax_rate: 0.2
            }
          ]
        }
      end

      let(:first_version_first_item) { quote.versions.first.items.find_by(name: "Item 1") }
      let(:first_version_second_item) { quote.versions.first.items.find_by(name: "Item 2") }

      let(:expected) { }

      response "200", "quote updated" do
        schema Organization::Projects::Quotes::ShowDto.to_schema
        context "with valid params" do
          it "Updates the quote by updating updatable attributes and by creating a new version", :aggregate_failures do |example|
            expect { submit_request(example.metadata) }
              .to not_change(Organization::Quote, :count)
              .and change(Organization::ProjectVersion, :count).by(1)
              .and change(Organization::Item, :count).by(3)

            assert_response_matches_metadata(example.metadata)

            response_json = JSON.parse(response.body)["result"]
            expect(response_json["address_street"]).to eq("10 Rue de la mise à jour")
            expect(response_json["address_zipcode"]).to eq("75002")
            expect(response_json["address_city"]).to eq("Paris")
            expect(response_json["po_number"]).to eq("PO123456_UPDATED")
          end
        end

        context "when there is updated items" do
          run_test!("creates new item record but take the name, description and unit from the original record") {
            new_version_first_item = quote.last_version.items.find_by(original_item_uuid: first_version_first_item.original_item_uuid)
            expect(new_version_first_item.name).to eq("Item 1")
            expect(new_version_first_item.description).to eq("First item")
            expect(new_version_first_item.unit).to eq("unit")
          }
        end

        context "when discounts are added" do
          let(:body) do
            valid_body.merge({
              new_discounts: [
                {
                  kind: "fixed_amount",
                  value: 30,
                  position: 1,
                  name: "New discount"
                }
              ]
            })
          end

          it "creates a new version with discounts", :aggregate_failures do |example|
            expect { submit_request(example.metadata) }
              .to not_change(Organization::Quote, :count)
              .and change(Organization::ProjectVersion, :count).by(1)
              .and change(Organization::Discount, :count).by(1)

            assert_response_matches_metadata(example.metadata)

            quote.reload
            discount = quote.last_version.discounts.first
            expect(discount.kind).to eq("fixed_amount")
            expect(discount.value).to eq(30)
            expect(discount.amount).to eq(30)
            expect(discount.name).to eq("New discount")
          end
        end

        context "when updating a quote that had discounts" do
          let!(:quote_with_discount) do
            ::Organization::Quotes::Create.call(
              company.id,
              client.id,
              company.bank_details.last.id,
              {
                name: "Quote Update Discount Test",
                retention_guarantee_rate: 0.05,
                po_number: "PO_DISCOUNT",
                address_street: "10 Rue de la Paix",
                address_zipcode: "75002",
                address_city: "Paris",
                groups: [
                  { uuid: "group-1", name: "Group 1", position: 0 }
                ],
                items: [
                  {
                    group_uuid: "group-1",
                    name: "Original Item",
                    position: 0,
                    unit: "unit",
                    unit_price_amount: 200.0,
                    quantity: 5,
                    tax_rate: 0.2
                  }
                ],
                discounts: [
                  {
                    kind: "percentage",
                    value: 0.1,
                    position: 1,
                    name: "Original discount 10%"
                  }
                ]
              }
            ).data
          end

          let(:id) { quote_with_discount.id }
          let(:original_item) { quote_with_discount.last_version.items.first }

          let(:body) do
            {
              name: "Quote Update Discount Test UPDATED",
              description: "Updated",
              retention_guarantee_rate: 0.05,
              bank_detail_id: company.bank_details.last.id,
              po_number: "PO_UPDATED",
              address_street: "20 Rue Updated",
              address_zipcode: "75002",
              address_city: "Paris",
              groups: [
                { uuid: "group-1", name: "Group 1", position: 0 }
              ],
              new_items: [],
              updated_items: [
                {
                  original_item_uuid: original_item.original_item_uuid,
                  group_uuid: "group-1",
                  position: 0,
                  unit_price_amount: 250.0,
                  quantity: 4,
                  tax_rate: 0.2
                }
              ],
              updated_discounts: [
                {
                  original_discount_uuid: quote_with_discount.last_version.discounts.first.original_discount_uuid,
                  kind: "fixed_amount",
                  value: 100,
                  position: 1
                }
              ],
              new_discounts: [
                {
                  kind: "percentage",
                  value: 0.05,
                  position: 2,
                  name: "Additional 5%"
                }
              ]
            }
          end

          it "updates the quote with new discounts", :aggregate_failures do |example|
            expect { submit_request(example.metadata) }
              .to not_change(Organization::Quote, :count)
              .and change(Organization::ProjectVersion, :count).by(1)
              .and change(Organization::Discount, :count).by(2)

            assert_response_matches_metadata(example.metadata)

            quote_with_discount.reload
            discounts = quote_with_discount.last_version.discounts.ordered
            expect(discounts.count).to eq(2)

            # First discount
            expect(discounts.first.kind).to eq("fixed_amount")
            expect(discounts.first.amount).to eq(100)
            expect(discounts.first.name).to eq("Original discount 10%")

            # Second discount: (250*4 - 100) * 0.05 = 45
            expect(discounts.second.kind).to eq("percentage")
            expect(discounts.second.value).to eq(0.05)
            expect(discounts.second.amount).to eq(45)
            expect(discounts.second.name).to eq("Additional 5%")
          end
        end
      end

      response "404", "quote not found" do
        context "when the quote does not exist" do
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
                bank_detail_id: company.bank_details.last.id,
                description: "Updated Description of the new quote",
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

          context "when the quote is already posted" do
            before {
              Organization::Quotes::ConvertToDraftOrder.call(quote.id)
            }

            run_test!
          end
        end
      end
    end
  end
  path "/api/v1/organization/companies/{company_id}/clients/{client_id}/quotes" do
    post "Create a new quote for a client" do
      tags "Quotes"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :client_id, in: :path, type: :integer
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          client_id: { type: :number },
          name: { type: :string },
          description: { type: :string },
          po_number: { type: :string },
          address_street: { type: :string },
          address_city: { type: :string },
          address_zipcode: { type: :string },
          retention_guarantee_rate: { type: :number },
          items: {
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
          },
          discounts: {
            type: :array,
            items: {
              type: :object,
              properties: {
                name: { type: :string },
                kind: { type: :string, enum: [ "percentage", "fixed_amount" ] },
                value: { type: :number, format: :decimal },
                position: { type: :integer }
              },
              required: [ "name", "kind", "value", "position" ]
            }
          }
        },
        required: [ "name", "retention_guarantee_rate", "items", "discounts", "address_street", "address_zipcode", "address_city" ]
      }

      let(:user) { FactoryBot.create(:user) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:client_id) { client.id }
      let(:bank_detail_id) { company.bank_details.last.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let(:body) do
        {
          bank_detail_id: bank_detail_id,
          name: "New Quote",
          description: "Description of the new quote",
          po_number: "PO_123456",
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
              position: 0,
              unit: "unit",
              unit_price_amount: 100.0,
              quantity: 1,
              tax_rate: 0.2
            }
          ]
        }
      end

      include_context 'a company with a project with three item groups'

      response "201", "quote created" do
        schema Organization::Projects::Quotes::ShowDto.to_schema

        context "when no discounts are provided" do
          run_test! do
            parsed_response = JSON.parse(response.body)
            expect(parsed_response.dig("result", "name")).to eq("New Quote")
            expect(parsed_response.dig("result", "po_number")).to eq("PO_123456")
          end
        end

        context "when discounts are provided with fixed amount" do
          let(:body) do
            {
              bank_detail_id: bank_detail_id,
              name: "Quote Fixed Discount Test",
              description: "Description of the quote",
              po_number: "PO_789",
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
                  position: 0,
                  unit: "unit",
                  unit_price_amount: 100.0,
                  quantity: 2,
                  tax_rate: 0.2
                }
              ],
              discounts: [
                {
                  kind: "fixed_amount",
                  value: 20,
                  position: 1,
                  name: "Commercial discount"
                }
              ]
            }
          end

          it "creates a quote with discount", :aggregate_failures do |example|
            expect { submit_request(example.metadata) }
              .to change(Organization::Quote, :count).by(1)
              .and change(Organization::Discount, :count).by(1)

            assert_response_matches_metadata(example.metadata)

            parsed_response = JSON.parse(response.body)
            quote_id = parsed_response.dig("result", "id")
            created_quote = Organization::Quote.find(quote_id)

            # Verify discount was created
            discounts = created_quote.last_version.discounts
            expect(discounts.count).to eq(1)

            discount = discounts.first
            expect(discount.kind).to eq("fixed_amount")
            expect(discount.value).to eq(20)
            expect(discount.amount).to eq(20)
            expect(discount.position).to eq(1)
            expect(discount.name).to eq("Commercial discount")
            expect(discount.original_discount_uuid).to be_present
          end
        end

        context "when discounts are provided with percentage" do
          let(:body) do
            {
              bank_detail_id: bank_detail_id,
              name: "Quote Percentage Discount Test",
              description: "Description",
              po_number: "PO_999",
              retention_guarantee_rate: 0.05,
              address_street: "10 Rue de la Paix",
              address_zipcode: "75002",
              address_city: "Paris",
              groups: [
                { uuid: "group-1", name: "Group 1", position: 0 }
              ],
              items: [
                {
                  group_uuid: "group-1",
                  name: "Item 1",
                  position: 0,
                  unit: "unit",
                  unit_price_amount: 500.0,
                  quantity: 4,
                  tax_rate: 0.2
                }
              ],
              discounts: [
                {
                  kind: "percentage",
                  value: 0.15,
                  position: 1,
                  name: "Volume discount 15%"
                }
              ]
            }
          end

          it "creates a quote with percentage discount and calculates amount correctly", :aggregate_failures do |example|
            submit_request(example.metadata)
            assert_response_matches_metadata(example.metadata)

            parsed_response = JSON.parse(response.body)
            quote_id = parsed_response.dig("result", "id")
            created_quote = Organization::Quote.find(quote_id)

            discount = created_quote.last_version.discounts.first
            expect(discount.kind).to eq("percentage")
            expect(discount.value).to eq(0.15)
            # Total items: 500 * 4 = 2000, 15% = 300
            expect(discount.amount).to eq(300)
            expect(discount.name).to eq("Volume discount 15%")
          end
        end

        context "when multiple discounts are provided" do
          let(:body) do
            {
              bank_detail_id: bank_detail_id,
              name: "Quote Multiple Discounts Test",
              description: "Description",
              po_number: "PO_MULTI",
              retention_guarantee_rate: 0.05,
              address_street: "10 Rue de la Paix",
              address_zipcode: "75002",
              address_city: "Paris",
              groups: [
                { uuid: "group-1", name: "Group 1", position: 0 }
              ],
              items: [
                {
                  group_uuid: "group-1",
                  name: "Item 1",
                  position: 0,
                  unit: "unit",
                  unit_price_amount: 1000.0,
                  quantity: 1,
                  tax_rate: 0.2
                }
              ],
              discounts: [
                {
                  kind: "fixed_amount",
                  value: 50,
                  position: 1,
                  name: "Early payment"
                },
                {
                  kind: "percentage",
                  value: 0.05,
                  position: 2,
                  name: "Loyalty 5%"
                }
              ]
            }
          end

          it "creates a quote with multiple discounts", :aggregate_failures do |example|
            expect { submit_request(example.metadata) }
              .to change(Organization::Quote, :count).by(1)
              .and change(Organization::Discount, :count).by(2)

            assert_response_matches_metadata(example.metadata)

            parsed_response = JSON.parse(response.body)
            quote_id = parsed_response.dig("result", "id")
            created_quote = Organization::Quote.find(quote_id)

            discounts = created_quote.last_version.discounts.ordered
            expect(discounts.count).to eq(2)

            # First discount
            expect(discounts.first.kind).to eq("fixed_amount")
            expect(discounts.first.value).to eq(50)
            expect(discounts.first.amount).to eq(50)
            expect(discounts.first.position).to eq(1)

            # Second discount - applied after first: (1000 - 50) * 0.05 = 47.5
            expect(discounts.second.kind).to eq("percentage")
            expect(discounts.second.value).to eq(0.05)
            expect(discounts.second.amount).to eq(47.5)
            expect(discounts.second.position).to eq(2)
          end
        end
      end

      response "422", "unprocessable entity" do
        let(:body) { { bank_detail_id: bank_detail_id, name: "" } } # Invalid params

        run_test! do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response["error"]).to be_present
        end
      end

      response "404", "client not found" do
        context "when the user is not a member of the company" do
          let(:company_id) { FactoryBot.create(:company).id }

          run_test! do
            expect(response.body).to include("Resource not found")
          end
        end

        context "when the client is not one of the comapny's client" do
          let(:another_company) { FactoryBot.create(:company) }
          let(:client_id) { FactoryBot.create(:client, company: another_company).id }

          run_test! do
            expect(response.body).to include("Resource not found")
          end
        end

        context "when the company does not exists" do
          let(:company_id) { -1 }

          run_test! do
            expect(response.body).to include("Resource not found")
          end
        end

        context "when the client does not exists" do
          let(:client_id) { -1 }

          run_test! do
            expect(response.body).to include("Resource not found")
          end
        end
      end

      response "404", "bank_detail not found" do
        context "when the bank_detail is not one of the comapny's bank_details" do
          let(:another_company) { FactoryBot.create(:company) }
          let(:bank_detail_id) { FactoryBot.create(:bank_detail, company: another_company).id }

          run_test! do
            expect(response.body).to include("Resource not found")
          end
        end

        context "when the bank_detail does not exists" do
          let(:bank_detail_id) { -1 }

          run_test! do
            expect(response.body).to include("Resource not found")
          end
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
  path "/api/v1/organization/quotes/{id}/convert_to_draft_order" do
    post "Convert a quote to an order" do
      tags "Quotes"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      let(:id) { quote.id }

      include_context 'a company with a project with three item groups'

      response "201", "quote converted to order" do
        schema Organization::Projects::DraftOrders::ShowDto.to_schema
        before { draft_order.destroy }

        run_test! do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response.dig("result", "original_project_version_id")).to eq(quote.last_version.id)
        end
      end

      response "404", "quote not found" do
        let(:id) { -1 } # Non-existent quote ID

        run_test! do
          expect(response.body).to include("Resource not found")
        end
      end

      response "422", "unprocessable entity" do
        context "when the quote have already been converted" do
          run_test! do
            expect(response.body).to include("Quote has already been converted to an draft order")
          end
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
end
# rubocop:enable RSpec/ExampleLength
