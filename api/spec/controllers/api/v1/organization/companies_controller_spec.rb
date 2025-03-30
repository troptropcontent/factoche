require "rails_helper"
require 'swagger_helper'

RSpec.describe Api::V1::Organization::CompaniesController, type: :request do
  path '/api/v1/organization/companies' do
    get 'Lists user companies' do
      tags 'Companies'
      security [ bearerAuth: [] ]
      produces 'application/json'

      response '200', 'successfully lists user\'s companies' do
        let(:user) { FactoryBot.create(:user) }
        let(:company) { FactoryBot.create(:company, :with_config) }
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

      response '403', 'forbidden' do
        let(:Authorization) { 'invalid_token' }
        schema ApiError.schema

        run_test!
      end
    end
  end

  path '/api/v1/organization/companies/{id}' do
    get 'Shows a specific company' do
      tags 'Companies'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      response '200', 'successfully shows the company' do
        schema ::Organization::Companies::ShowDto.to_schema

        let(:user) { FactoryBot.create(:user) }
        let(:company) { FactoryBot.create(:company, :with_config) }
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        let(:id) { company.id }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }


        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.dig("result", "id")).to eq(company.id)
        end
      end

      response '403', 'forbidden' do
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

    put 'Updates a company' do
      tags 'Companies'
      security [ bearerAuth: [] ]
      produces 'application/json'
      consumes 'application/json'
      parameter name: :id, in: :path, type: :integer
      parameter name: :body, in: :body, schema: {
        type: :object,
        properties: {
          name: { type: :string },
          registration_number: { type: :string },
          email: { type: :string },
          phone: { type: :string },
          address_city: { type: :string },
          address_street: { type: :string },
          address_zipcode: { type: :string },
          legal_form: { type: :string, enum: Organization::Company.legal_forms.values },
          rcs_city: { type: :string },
          rcs_number: { type: :string },
          vat_number: { type: :string },
          capital_amount: { type: :number },
          configs: {
            type: :object,
            properties: {
              general_terms_and_conditions: { type: :string },
              default_vat_rate: { type: :number },
              payment_term_days: { type: :integer },
              payment_term_accepted_methods: { type: :array, items: { type: :string, enum: Organization::CompanyConfig::ALLOWED_PAYMENT_METHODS } }
            }
          }
        }
      }

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company, :with_config) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:id) { company.id }

      response '200', 'company updated successfully' do
        schema ::Organization::Companies::ShowDto.to_schema

        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        let(:body) do
          {
              name: 'Updated Company Name',
              registration_number: 'NEW123',
              email: 'updated@example.com',
              phone: "+33611111111",
              address_city: 'New City',
              address_street: 'New Street',
              address_zipcode: '12345',
              configs: {
                default_vat_rate: "0.1"
              }
            }
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data.dig("result", "name")).to eq('Updated Company Name')
          expect(data.dig("result", "registration_number")).to eq('NEW123')
          expect(data.dig("result", "email")).to eq('updated@example.com')
          expect(data.dig("result", "phone")).to eq("+33611111111")
          expect(data.dig("result", "address_city")).to eq('New City')
          expect(data.dig("result", "address_street")).to eq('New Street')
          expect(data.dig("result", "address_zipcode")).to eq('12345')
          expect(data.dig("result", "config", "default_vat_rate")).to eq("0.1")
        end
      end

      response '422', 'invalid request' do
        schema ApiError.schema

        let(:user) { FactoryBot.create(:user) }
        let(:company) { FactoryBot.create(:company, :with_config) }
        let!(:member) { FactoryBot.create(:member, user:, company:) }
        let(:id) { company.id }
        let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
        let(:body) do
          {
            company: {
              name: '', # invalid empty name
              email: 'not_an_email' # invalid email format
            }
          }
        end

        run_test!
      end

      response '404', 'company not found' do
        context "when the company does not exists" do
          let(:user) { FactoryBot.create(:user) }
          let(:id) { 999999 }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
          let(:body) { { company: { name: 'New Name' } } }

          schema ApiError.schema

          run_test! "it returns a 404"
        end

        context "when the use is not a member of the company" do
          let(:another_user) { FactoryBot.create(:user) }
          let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(another_user.id)}" }
          let(:body) { { company: { name: 'New Name' } } }

          schema ApiError.schema

          run_test! "it returns a 404"
        end
      end
    end
  end
end
