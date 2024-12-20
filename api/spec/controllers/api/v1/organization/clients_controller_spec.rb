require 'rails_helper'
require 'swagger_helper'

RSpec.describe Api::V1::Organization::ClientsController, type: :request, focus: true do
  path '/api/v1/organization/companies/{company_id}/clients' do
    post 'Creates a client for a company' do
      tags 'Clients'
      security [ bearer_auth: [] ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :client, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          registration_number: { type: :string },
          email: { type: :string },
          phone: { type: :string },
          address_street: { type: :string },
          address_city: { type: :string },
          address_zipcode: { type: :string }
        },
        required: [ 'name', 'registration_number', 'email', 'phone', 'address_street', 'address_city', 'address_zipcode' ]
      }

      response '200', 'client created' do
        let(:user) { FactoryBot.create(:user) }
        let(:company) { FactoryBot.create(:company) }
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        let(:company_id) { company.id }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        let(:client) do
          {
            name: 'Test Client',
            registration_number: '123456789',
            email: 'test@example.com',
            phone: '+33326567890',
            address_street: 'Test Street 123',
            address_city: 'Test City',
            address_zipcode: '12345'
          }
        end

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
          expect(data["name"]).to eq('Test Client')
          expect(Organization::Client.count).to eq(1)
        end
      end

      response '401', 'unauthorized' do
        let(:company_id) { 1 }
        let(:client) { valid_client_payload }

        describe 'with invalid token format' do
          let(:Authorization) { 'invalid_token' }
          schema ApiError.schema
          run_test!
        end

        describe 'with expired token' do
          let(:Authorization) { travel_to 1.day.before { "Bearer #{JwtAuth.generate_access_token(1)} " } }
          schema ApiError.schema
          run_test!
        end
      end

      response '404', 'company not found' do
        let(:user) { FactoryBot.create(:user) }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        let(:client) { valid_client_payload }

        describe "when the company does not exist" do
          let(:company_id) { 999999 }
          schema ApiError.schema
          run_test!
        end

        describe "when the user is not authorized to create client within this company" do
          let(:company) { FactoryBot.create(:company) }
          let(:company_id) { company.id }
          schema ApiError.schema
          run_test!
        end
      end

      response '422', 'client is invalid' do
        let(:user) { FactoryBot.create(:user) }
        let(:company) { FactoryBot.create(:company) }
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        let(:company_id) { company.id }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

        describe "when name is missing" do
          let(:client) { valid_client_payload.merge(name: nil) }
          schema ApiError.schema
          run_test!
        end

        describe "when email is invalid" do
          let(:client) { valid_client_payload.merge(email: 'invalid-email') }
          schema ApiError.schema
          run_test!
        end

        describe "when registration number is missing" do
          let(:client) { valid_client_payload.merge(registration_number: nil) }
          schema ApiError.schema
          run_test!
        end

        describe "when phone is invalid" do
          let(:client) { valid_client_payload.merge(phone: 'invalid-phone') }
          schema ApiError.schema
          run_test!
        end
      end
    end
  end
end

def valid_client_payload
  {
    name: 'Test Client',
    registration_number: '123456789',
    email: 'test@example.com',
    phone: '+33326567890',
    address_street: 'Test Street 123',
    address_city: 'Test City',
    address_zipcode: '12345'
  }
end
