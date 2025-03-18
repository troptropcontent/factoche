require "rails_helper"
require "swagger_helper"
require "support/shared_contexts/organization/a_company_with_a_project_with_three_item_groups"
require_relative "shared_examples/an_authenticated_endpoint"

RSpec.describe Api::V1::Organization::QuotesController, type: :request do
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
        context "when the user is not a member of the company" do
          let(:another_user) { FactoryBot.create(:user) }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(another_user.id)}" }

          run_test!
        end

        context "when the quote does not exist" do
          let(:id) { 123123123123123123123123 }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

          run_test!
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
          name: { type: :string },
          description: { type: :string },
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
          }
        },
        required: [ "name", "retention_guarantee_rate", "items" ]
      }

      let(:user) { FactoryBot.create(:user) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:client_id) { client.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let(:body) do
        {
          name: "New Quote",
          description: "Description of the new quote",
          retention_guarantee_rate: 0.05,
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
        run_test! do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response.dig("result", "name")).to eq("New Quote")
        end
      end

      response "422", "unprocessable entity" do
        let(:body) { { name: "" } } # Invalid params

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

      it_behaves_like "an authenticated endpoint"
    end
  end
  path "/api/v1/organization/quotes/{id}/convert_to_order" do
    post "Convert a quote to an order" do
      tags "Quotes"
      security [ bearerAuth: [] ]
      consumes "application/json"
      produces "application/json"
      parameter name: :id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let(:quote) { FactoryBot.create(:quote, client: client) }
      let(:id) { quote.id }

      include_context 'a company with a project with three item groups'

      response "201", "quote converted to order" do
        schema Organization::Projects::Orders::ShowDto.to_schema
        run_test! do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response.dig("result", "original_quote_version_id")).to eq(quote.last_version.id)
        end
      end

      response "404", "quote not found" do
        let(:id) { -1 } # Non-existent quote ID

        run_test! do
          expect(response.body).to include("Resource not found")
        end
      end

      response "422", "unprocessable entity" do
        before do
          allow(::Organization::Quotes::ConvertToOrder).to receive(:call).and_return(ServiceResult.failure("Conversion failed"))
        end

        run_test! do
          expect(response.body).to include("Conversion failed")
        end
      end

      it_behaves_like "an authenticated endpoint"
    end
  end
end
