require 'rails_helper'

RSpec.describe Accounting::FinancialTransactions::BuildCompletionSnapshotInvoiceDetailAttributes do
  describe '.call' do
    let(:issue_date) { Time.current }
    let(:payment_term_days) { 30 }

    let(:company) do
      {
        name: 'Acme Corp',
        registration_number: '123456789',
        address_zipcode: '12345',
        address_street: '123 Company St',
        address_city: 'Company City',
        vat_number: 'VAT123456',
        phone: '+33123456789',
        email: 'contact@acmecorp.com',
        config: {
          payment_term: {
            days: payment_term_days
          }
        }
      }
    end

    let(:client) do
      {
        name: 'Client Corp',
        registration_number: '987654321',
        address_zipcode: '54321',
        address_street: '456 Client St',
        address_city: 'Client City',
        vat_number: 'VAT987654',
        phone: '+33123456789',
        email: 'contact@clientcorp.com'
      }
    end

    let(:project_version) do
      {
        id: 'PO-123'
      }
    end

    context 'when all required data is present' do
      subject(:result) { described_class.call(company, client, project_version, issue_date) }

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
          client_name: client[:name],
          client_registration_number: client[:registration_number],
          client_address_zipcode: client[:address_zipcode],
          client_address_street: client[:address_street],
          client_address_city: client[:address_city],
          client_vat_number: client[:vat_number],
          delivery_name: client[:name],
          delivery_registration_number: client[:registration_number],
          delivery_address_zipcode: client[:address_zipcode],
          delivery_address_street: client[:address_street],
          delivery_address_city: client[:address_city],
          purchase_order_number: project_version[:id]
        )
      end
      # rubocop:enable RSpec/ExampleLength
    end

    context 'when required data is missing' do
      let(:company) { {} }

      it 'returns a failure result', :aggregate_failures do
        result = described_class.call(company, client, project_version, issue_date)

        expect(result).to be_failure
        expect(result.error).to include('Failed to build invoice detail attributes')
      end
    end
  end
end
