require "rails_helper"
require 'swagger_helper'

RSpec.describe Api::V1::Organization::CompaniesController, type: :request do
  path '/api/v1/organization/companies' do
    get 'Lists user companies' do
      tags 'Companies'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'company found' do
        let(:user) { FactoryBot.create(:user) }
        let(:company) { FactoryBot.create(:company) }
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer },
                   name: { type: :string },
                   registration_number: { type: :string },
                   email: { type: :string },
                   phone: { type: :string },
                   address_city: { type: :string },
                   address_street: { type: :string },
                   address_zipcode: { type: :string }
                 },
                 required: [ 'id', 'name', 'registration_number', 'email', 'phone', 'address_city', 'address_street', 'address_zipcode' ]
               }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.dig(0, "id")).to eq(company.id)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'invalid_token' }
        schema ApiError.schema

        run_test!
      end
    end
  end
end
