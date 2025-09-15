require 'rails_helper'
require 'swagger_helper'
require_relative "shared_examples/an_authenticated_endpoint"

RSpec.describe Api::V1::Organization::BankDetailsController, type: :request do
  path '/api/v1/organization/companies/{company_id}/bank_details' do
    get 'Lists clients for a company' do
      tags 'Bank Details'
      security [ bearerAuth: [] ]
      produces 'application/json'
      parameter name: :company_id, in: :path, type: :integer

      let(:user) { FactoryBot.create(:user) }
      let(:company) { FactoryBot.create(:company, :with_bank_detail) }
      let!(:member) { FactoryBot.create(:member, user:, company:) }
      let(:company_id) { company.id }
      let(:Authorization) { "Bearer #{JwtAuth.generate_access_token(user.id)}" }
      let!(:clients) { FactoryBot.create_list(:client, 3, company:) }

      response '200', 'bank_details found' do
        schema Organization::BankDetails::ShowDto.to_schema()
        run_test! do |response|
          expect(JSON.parse(response.body).length).to eq(1)
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
        describe "when the user is not authorized to view bank_details within this company" do
          let(:another_company) { FactoryBot.create(:company) }
          let(:company_id) { another_company.id }

          schema '$ref' => '#/components/schemas/error'
          run_test!
        end
      end
    end
  end
end
