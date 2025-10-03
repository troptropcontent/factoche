require 'rails_helper'

RSpec.describe Accounting::Proformas::BuildDetailAttributes do
  describe '.call' do
    let(:issue_date) { Time.current }
    let(:payment_term_days) { 30 }

    let(:project) { FactoryBot.build(:accounting_project_hash) }

    let(:company) { FactoryBot.build(:accounting_company_hash, id: 1) }

    let(:client) { FactoryBot.build(:accounting_client_hash, id: 1) }

    let(:project_version) { FactoryBot.build(:accounting_project_version_hash, id: 1) }

    context 'when all required data is present' do
      subject(:result) { described_class.call({ company:, client:, project:, project_version:, issue_date: }) }

      it 'returns a successful service result' do
        expect(result).to be_success
      end

      # rubocop:disable RSpec/ExampleLength
      it 'returns the correct attributes' do
        attributes = result.data

        expect(attributes).to include(
          delivery_date: issue_date,
          due_date: issue_date + payment_term_days.days,
          seller_name: company[:name],
          seller_registration_number: company[:registration_number],
          seller_address_zipcode: company[:address_zipcode],
          seller_address_street: company[:address_street],
          seller_address_city: company[:address_city],
          seller_vat_number: company[:vat_number],
          seller_rcs_city: company[:rcs_city],
          seller_rcs_number: company[:rcs_number],
          seller_legal_form: company[:legal_form],
          seller_capital_amount: company[:capital_amount],
          payment_term_days: company[:config][:payment_term_days],
          payment_term_accepted_methods: company[:config][:payment_term_accepted_methods],
          general_terms_and_conditions: company[:config][:general_terms_and_conditions],
          bank_detail_iban: company[:bank_detail][:iban],
          bank_detail_bic: company[:bank_detail][:bic],
          client_name: client[:name],
          client_registration_number: client[:registration_number],
          client_address_zipcode: client[:address_zipcode],
          client_address_street: client[:address_street],
          client_address_city: client[:address_city],
          client_vat_number: client[:vat_number],
          delivery_name: client[:name],
          delivery_registration_number: client[:registration_number],
          delivery_address_zipcode: project[:address_zipcode],
          delivery_address_street: project[:address_street],
          delivery_address_city: project[:address_city],
          purchase_order_number: project_version[:id],
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when required data is missing' do
      let(:company) { {} }

      it 'returns a failure result', :aggregate_failures do
        result = described_class.call({ company:, client:, project_version:, project:, issue_date: })

        expect(result).to be_failure
      end
    end
  end
end
