require 'rails_helper'

module Accounting
  module Proformas
    # rubocop:disable RSpec/MultipleMemoizedHelpers
    RSpec.describe BuildAttributes do
      describe '.call' do
        subject(:result) { described_class.call(company[:id], client[:id], project, project_version, new_invoice_items, issue_date) }

        let(:issue_date) { Time.current }

        let(:project) { { name: "Super Project" } }

        let(:new_invoice_items) do
          [
            { original_item_uuid: 'item-uuid-1', invoice_amount: "150" }
          ]
        end

        let(:project_version) do
          {
            id: 123,
            number: 1,
            created_at: 1.day.ago,
            retention_guarantee_rate: 0.1,
            items: [
              {
                original_item_uuid: 'item-uuid-1',
                group_id: 1,
                name: 'Item 1',
                description: 'Description 1',
                quantity: 2,
                unit: 'pieces',
                unit_price_amount: 100.0,
                tax_rate: 0.2
              }
            ],
            item_groups: [
              {
                id: 1,
                name: 'Group 1',
                description: 'Group Description'
              }
            ]
          }
        end

        let(:company) { {
          id: 1,
          name: "ACME Corp",
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
          },
          bank_detail: {
          iban: 'IBAN',
          bic: 'BIC'
        }
        } }

        let(:client) { {
          id: 1,
          name: "Client Corp",
          registration_number: "987654321",
          address_zipcode: "75002",
          address_street: "2 avenue des Champs-Élysées",
          address_city: "Paris",
          vat_number: "FR987654321",
          phone: "+33987654321",
          email: "contact@clientcorp.com"
        } }

        before do
          # Create a previously posted invoice for the item
          Create.call(company, client, project, project_version, [ {
            original_item_uuid: 'item-uuid-1',
            invoice_amount: 50
          } ], 2.days.ago).data.tap { |proforma| Accounting::Proformas::Post.call(proforma.id) }
        end

        it 'is a success' do
          expect(result).to be_success
        end

        # rubocop:disable RSpec/ExampleLength
        it 'returns success with correct invoice attributes', :aggregate_failures do
          expect(result.data).to include(
            company_id: company[:id],
            client_id: client[:id],
            holder_id: project_version[:id],
            status: :draft,
            issue_date: issue_date,
            total_excl_tax_amount: 150.0,
            total_including_tax_amount: 180.0,
            total_excl_retention_guarantee_amount: 162.0
          )

          context = result.data[:context]
          expect(context).to include(
            project_version_number: 1,
            project_version_date: project_version[:created_at].iso8601,
            project_version_retention_guarantee_rate: 0.1,
            project_total_amount: 200.0.to_d, # 2 * 100.0
            project_total_previously_billed_amount: 50.0.to_d # From the previous transaction
          )

          expect(context[:project_version_items].first).to include(
            original_item_uuid: 'item-uuid-1',
            previously_billed_amount: 50.0.to_d
          )

          expect(context[:project_version_item_groups].first).to include(
            id: 1,
            name: 'Group 1',
            description: 'Group Description'
          )
        end


          context 'when required data is missing' do
            let(:invalid_project_version) { { number: 'PV-001' } }

            it 'returns failure with error message', :aggregate_failures do
              result = described_class.call(company[:id], client[:id], project, invalid_project_version, new_invoice_items, issue_date)
              expect(result).not_to be_success
              expect(result.error).to include('Failed to build invoice attributes')
              expect(result.error).to include('PV-001')
            end
          end
          # rubocop:enable RSpec/ExampleLength
        end
      end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
