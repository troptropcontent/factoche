require "rails_helper"
require "swagger_helper"

RSpec.describe Api::V1::Organization::ProjectsController, type: :request do
  path "/api/v1/organization/companies/{company_id}/projects" do
    post "Creates a new project and its descendants" do
      tags 'Projects'
      security [ bearer_auth: [] ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :project, in: :body, schema: { oneOf: [
        { '$ref' => '#/components/schemas/create_project_with_item_groups' },
        { '$ref' => '#/components/schemas/create_project_with_items' }
      ] }

      response '200', 'project created', focus: true do
        let(:user) { FactoryBot.create(:user) }
        let(:company) { FactoryBot.create(:company) }
        let!(:client) { FactoryBot.create(:client, company: company) }
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        let(:company_id) { company.id }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        describe "simple project, without item groups" do
          let(:project) {
          {
            name: "Amazing Project",
            project_version_attributes: {
              retention_guarantee_rate: 500,
              items_attributes: [
                { name: "Screws", unit: "ENS", unit_price: 1500, quantity: 4 },
                { name: "Bolts", unit: "ENS", unit_price: 2000, quantity: 8 }
              ]
            }
          }
        }
          run_test!
        end
        describe "advanced project, with item groups" do
          let(:project) {
            {
              name: "Amazing Project",
              project_version_attributes: {
                retention_guarantee_rate: 500,
                item_groups_attributes: {
                  name: "Building",
                  items_attributes: [
                    { name: "Screws", unit: "ENS", unit_price: 1500, quantity: 4 },

                    { name: "Bolts", unit: "ENS", unit_price: 2000, quantity: 8 }
                  ]
                }
              }
            }
          }
          run_test!
        end
      end
    end
  end
end
