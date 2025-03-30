require 'rails_helper'

module Accounting
  module Invoices
    # rubocop:disable RSpec/MultipleMemoizedHelpers
    RSpec.describe Update do
      describe '.call' do
        subject(:result) { described_class.call(invoice_id, company, client, project, project_version, new_invoice_items, issue_date) }
        let(:invoice_id) { original_invoice.id }
        let(:issue_date) { Date.new(2024, 1, 9) }
        let(:company_id) { 1 }
        let(:new_invoice_items) { [ {
          original_item_uuid: first_item_uuid,
          invoice_amount: "125.23"
        } ] }
        let(:project) { { name: "Super Project" } }
        let(:project_version_id) { 2 }
        let(:first_item_uuid) { "item-1" }
        let(:project_version) do
          {
            id: project_version_id,
            number: 1,
            created_at: 1.day.ago,
            retention_guarantee_rate: "0.05",
            items: [
              {
                original_item_uuid: first_item_uuid,
                name: "Item 1",
                description: "Description 1",
                quantity: 2,
                unit: "units",
                unit_price_amount: 100,
                tax_rate: "0.2",
                group_id: 1
              },
              {
                original_item_uuid: "item-2",
                name: "Item 2",
                description: "Description 2",
                quantity: 1,
                unit: "hours",
                unit_price_amount: 50,
                tax_rate: "0.2",
                group_id: 1
              }
            ],
            item_groups: [
              {
                id: 1,
                name: "Group 1",
                description: "Group Description 1"
              }
            ]
          }
        end
        let(:company) { {
          id: company_id,
          name: "New Name",
          registration_number: "123456789",
          address_zipcode: "75001",
          address_street: "1 rue de la Paix",
          address_city: "Paris",
          vat_number: "FR123456789",
          phone: "+33123456789",
          email: "contact@acmecorp.com",
          rcs_city: "Paris",
          rcs_number: "RCS123456",
          legal_form: "sas",
          capital_amount: 10000,
          config: {
            payment_term_days: 30,
            payment_term_accepted_methods: [ 'transfer' ],
            general_terms_and_conditions: '<h1>Condition<h1/>'
          }
        } }

        let(:client) { {
          name: "Client Corp",
          registration_number: "987654321",
          address_zipcode: "75002",
          address_street: "2 avenue des Champs-Élysées",
          address_city: "Paris",
          vat_number: "FR987654321",
          phone: "+33987654321",
          email: "contact@clientcorp.com"
        } }

        let!(:original_invoice) {
          Create.call(company.merge({ name: "OLD NAME" }), client.merge({ name: "OLD Client NAME" }), project, project_version, [ {
          original_item_uuid: first_item_uuid,
          invoice_amount: 50
        } ], issue_date).data}

        context 'when successful' do
          # rubocop:disable RSpec/ExampleLength

          it { is_expected.to be_success }

          it 'voids the invoice and create a new one', :aggregate_failures do
            expect { result }
              .to change(Accounting::Invoice, :count).by(1)
              .and change(Accounting::FinancialTransactionDetail, :count).by(1)
              .and change(Accounting::FinancialTransactionLine, :count).by(1)

            expect(original_invoice.reload.status).to eq("voided")
            expect(result.data.status).to eq("draft")
            expect(result.data.number).to eq("PRO-2024-000002")
          end
          # rubocop:enable RSpec/ExampleLength
        end

        context 'when there is an error' do
          let(:invoice_id) { "an_id_that_dont_exists" }

          it { is_expected.to be_failure }

          it 'returns a failure result', :aggregate_failures do
            expect(result.error).to include("Failed to update invoice")
          end
        end
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
