require "rails_helper"
require 'swagger_helper'

RSpec.describe Api::V1::Organization::CompaniesController, type: :request do
  path '/api/v1/organization/companies' do
    get 'Lists user companies' do
      tags 'Companies'
      security [ bearer_auth: [] ]
      produces 'application/json'

      response '200', 'successfully lists user\'s companies' do
        let(:user) { FactoryBot.create(:user) }
        let(:company) { FactoryBot.create(:company) }
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        let(:another_user) { FactoryBot.create(:user) }
        let(:another_company) { FactoryBot.create(:company) }
        let!(:another_member) { FactoryBot.create(:member, user: another_user, company: another_company) }
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
          expect(data.length).to eq(1)
        end
      end

      response '401', 'unauthorized' do
        let(:Authorization) { 'invalid_token' }
        schema ApiError.schema

        run_test!
      end
    end
  end

  path '/api/v1/organization/companies/{id}' do
    get 'Shows a specific company' do
      tags 'Companies'
      security [ bearer_auth: [] ]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'successfully shows the company' do
        let(:user) { FactoryBot.create(:user) }
        let(:company) { FactoryBot.create(:company) }
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        let(:id) { company.id }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

        schema type: :object,
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

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["id"]).to eq(company.id)
        end
      end

      response '401', 'unauthorized' do
        let(:id) { 1 }
        let(:Authorization) { 'invalid_token' }
        schema ApiError.schema

        run_test!
      end

      response '404', 'not found' do
        let(:user) { FactoryBot.create(:user) }
        let(:id) { 999999 }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        schema ApiError.schema

        run_test!
      end
    end
  end
end
