require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"

RSpec.describe Api::V1::Organization::ClientsController, type: :request do
  path '/api/v1/organization/companies/{company_id}/clients' do
    post 'Creates a client for a company' do
      tags 'Clients'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :client, in: :body, required: true, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          registration_number: { type: :string },
          vat_number: { type: :string },
          email: { type: :string },
          phone: { type: :string },
          address_street: { type: :string },
          address_city: { type: :string },
          address_zipcode: { type: :string }
        },
        required: [ 'name', 'email', 'phone', 'address_street', 'address_city', 'address_zipcode' ]
      }

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:client) { {} }

      response '200', 'client created' do
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        let(:client) do
          {
            name: 'Test Client',
            registration_number: '123456789',
            email: 'test@example.com',
            phone: '+33326567890',
            address_street: 'Test Street 123',
            address_city: 'Test City',
            address_zipcode: '12345',
            vat_number: '1234'
          }
        end

        schema '$ref' => '#/components/schemas/client'

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data["name"]).to eq('Test Client')
          expect(Organization::Client.count).to eq(1)
        end
      end

      it_behaves_like "an authenticated endpoint"

      response '404', 'company not found' do
        let(:user) { FactoryBot.create(:user) }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        let(:client) { valid_client_payload }

        describe "when the company does not exist" do
          let(:company_id) { 999999 }

          schema '$ref' => '#/components/schemas/error'
          run_test!
        end
      end

      response '401', 'user can not create a client within this company' do
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        let(:another_company) { FactoryBot.create(:company) }
        let(:company_id) { another_company.id }

        schema '$ref' => '#/components/schemas/error'
        run_test!
      end

      response '422', 'client is invalid' do
        let(:user) { FactoryBot.create(:user) }
        let(:company) { FactoryBot.create(:company) }
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        let(:company_id) { company.id }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

        describe "when name is missing" do
          let(:client) { valid_client_payload.merge(name: nil) }

          schema '$ref' => '#/components/schemas/error'
          run_test!
        end

        describe "when email is invalid" do
          let(:client) { valid_client_payload.merge(email: 'invalid-email') }

          schema '$ref' => '#/components/schemas/error'
          run_test!
        end

        describe "when phone is invalid" do
          let(:client) { valid_client_payload.merge(phone: 'invalid-phone') }

          schema '$ref' => '#/components/schemas/error'
          run_test!
        end
      end
    end
    get 'Lists clients for a company' do
      tags 'Clients'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let!(:clients) { FactoryBot.create_list(:client, 3, company:) }

      response '200', 'clients found' do
        schema type: :array, items: { '$ref' => '#/components/schemas/client' }
        run_test! do |response|
          expect(JSON.parse(response.body).length).to eq(3)
        end
      end

      response '404', 'company not found' do
        describe "when the company does not exist" do
          let(:company_id) { 999999 }

          schema '$ref' => '#/components/schemas/error'
          run_test!
        end
      end

      response '401', 'unauthorised' do
        describe "when the user is not authorized to view clients within this company" do
          let(:another_company) { FactoryBot.create(:company) }
          let(:company_id) { another_company.id }

          schema '$ref' => '#/components/schemas/error'
          run_test!
        end
      end
    end
  end
  path '/api/v1/organization/clients/{id}' do
    get 'Show client' do
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:client) { FactoryBot.create(:client, company:) }
      let(:id) { client.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      it_behaves_like "an authenticated endpoint"

      response "200", "client's details" do
        schema Organization::Clients::ShowDto.to_schema

        run_test!
      end

      response "404", "not found" do
        schema '$ref' => '#/components/schemas/error'

        context "when the client does not exists" do
          let(:id) { 123412341234134 }

          run_test!
        end

        context "when the client does not belong to a company of wich the user is a member" do
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(FactoryBot.create(:user).id)}" }

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
