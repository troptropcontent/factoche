require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"

RSpec.describe Api::V1::Organization::FinancialYearsController, type: :request do
  path '/api/v1/organization/companies/{company_id}/financial_years' do
    get 'Lists financial years for a company' do
      tags 'Financial Years'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }

      response '200', 'financial_years found' do
        schema Organization::FinancialYears::IndexDto.to_schema()
        run_test! do |response|
          expect(JSON.parse(response.body)['results'].length).to eq(1)
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
        describe "when the user is not a member of the company" do
          let(:another_company) { FactoryBot.create(:company) }
          let(:company_id) { another_company.id }

          schema '$ref' => '#/components/schemas/error'
          run_test!
        end
      end
    end

    post 'Creates a financial year for a company' do
      tags 'Financial Years'
      security [ bearerAuth: [] ]
      consumes 'application/json'
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer
      parameter name: :body, in: :body, schema: {
        type: :object,
        required: [ 'financial_year' ],
        properties: {
          financial_year: {
            type: :object,
            required: [ 'start_date', 'end_date' ],
            properties: {
              start_date: { type: :string, format: :'date-time' },
              end_date: { type: :string, format: :'date-time' }
            }
          }
        }
      }

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }

      response '201', 'financial_year created' do
        schema Organization::FinancialYears::ShowDto.to_schema()
        let(:body) do
          {
            financial_year: {
              start_date: Time.current.beginning_of_year.iso8601,
              end_date: Time.current.end_of_year.iso8601
            }
          }
        end
        run_test!
      end

      response '422', 'unprocessable entity' do
        schema '$ref' => '#/components/schemas/error'
        let!(:existing_year) { FactoryBot.create(:financial_year, company_id: company.id) }
        let(:body) do
          {
            financial_year: {
              start_date: Time.current.beginning_of_year.iso8601,
              end_date: Time.current.end_of_year.iso8601
            }
          }
        end
        run_test!
      end

      response '401', 'unauthorised' do
        describe "when the user is not a member of the company" do
          let(:another_company) { FactoryBot.create(:company) }
          let(:company_id) { another_company.id }
          let(:body) do
            {
              financial_year: {
                start_date: Time.current.beginning_of_year.iso8601,
                end_date: Time.current.end_of_year.iso8601
              }
            }
          end

          schema '$ref' => '#/components/schemas/error'
          run_test!
        end
      end
    end
  end

  path '/api/v1/organization/financial_years/{id}/renew' do
    post 'Renews a financial year to the next period' do
      tags 'Financial Years'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let!(:financial_year) { FactoryBot.create(:financial_year, company_id: company.id) }
      let(:id) { financial_year.id }

      response '201', 'financial_year renewed' do
        schema Organization::FinancialYears::ShowDto.to_schema()
        run_test!
      end

      response '422', 'unprocessable entity' do
        schema '$ref' => '#/components/schemas/error'
        let!(:next_year) { FactoryBot.create(:financial_year, company_id: company.id, start_date: Time.current.beginning_of_year.next_year, end_date: Time.current.end_of_year.next_year) }
        run_test!
      end

      response '401', 'unauthorised' do
        describe "when the financial year belongs to another company" do
          let(:another_company) { FactoryBot.create(:company) }
          let!(:other_financial_year) { FactoryBot.create(:financial_year, company_id: another_company.id) }
          let(:id) { other_financial_year.id }

          schema '$ref' => '#/components/schemas/error'
          run_test!
        end
      end
    end
  end
end
