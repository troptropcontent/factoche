require 'rails_helper'

module Accounting
  module Proformas
    # rubocop:disable RSpec/MultipleMemoizedHelpers
    RSpec.describe Create do
      describe '.call' do
        subject(:result) { described_class.call({ company:, client:, project:, project_version:, new_invoice_items: proforma_items, issue_date:, snapshot_number: }) }
        let(:snapshot_number) { 1 }
        let(:issue_date) { Time.new(2024, 3, 20) }
        let(:company_id) { 1 }
        let(:client_id) { 1 }
        let(:proforma_items) { [ {
          original_item_uuid: first_item_uuid,
          invoice_amount: "125.23"
        } ] }
        let(:project_version_id) { 2 }
        let(:first_item_uuid) { "item-1" }
        let(:project) { { name: "Super Project" } }
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
          id: client_id,
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
          FactoryBot.create(:financial_year, company_id: company[:id], start_date: issue_date.beginning_of_year, end_date: issue_date.end_of_year)
          # Create a previous proforma
          previous_posted_proforma_items = [ {
            original_item_uuid: first_item_uuid,
            invoice_amount: 50
            } ]

          result = described_class.call({ company:, client:, project:, project_version:, new_invoice_items: previous_posted_proforma_items, issue_date:, snapshot_number: })

          previous_posted_proforma = result.data

          previous_posted_proforma = Accounting::Proformas::Post.call(previous_posted_proforma.id).data
        end

        context 'when successful' do
          # rubocop:disable RSpec/ExampleLength
          before do
            allow(Accounting::FinancialTransactions::GenerateAndAttachPdfJob).to receive(:perform_async)
          end

          it { is_expected.to be_success }

          it 'creates a draft proforma', :aggregate_failures do
            expect(result.data).to be_a(Proforma)

            proforma = result.data
            expect(proforma.company_id).to eq(company_id)
            expect(proforma.holder_id).to eq(project_version_id)
            expect(proforma.status).to eq("draft")
            expect(proforma.number).to eq("PRO-2024-03-000002")

            expect(proforma.context["project_name"]).to eq("Super Project")
            expect(proforma.context["project_version_number"]).to eq(1)
            expect(proforma.context["project_total_amount"]).to eq("250.0") # (2 * 100 € ) + (1 * 50 €)
            expect(proforma.context["project_version_items"]).to be_present
            expect(proforma.context["project_version_item_groups"]).to be_present
          end
          # rubocop:enable RSpec/ExampleLength

          it 'creates the relevant invoice lines', :aggregate_failures do
            proforma = result.data

            expect(proforma.lines.count).to eq(1)
            expect(proforma.lines.first.excl_tax_amount).to eq('125.23'.to_d)

            expect(proforma.lines.first.quantity).to eq("1.2523".to_d) # 125 € (invoice amount) / 100 € (unit price) => the proportional quantity required to reach the amount invoiced
          end

          # rubocop:disable RSpec/ExampleLength
          it 'creates the relevant invoice detail', :aggregate_failures do
            proforma = result.data

            expect(proforma.detail).to be_present
            expect(proforma.detail).to have_attributes(
              delivery_date: be_within(1.second).of(issue_date),
              due_date: be_within(1.second).of(issue_date + 30.days),
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
              client_vat_number: client[:vat_number],
              client_name: client[:name],
              client_registration_number: client[:registration_number],
              client_address_zipcode: client[:address_zipcode],
              client_address_street: client[:address_street],
              client_address_city: client[:address_city],
              delivery_name: client[:name],
              delivery_registration_number: client[:registration_number],
              delivery_address_zipcode: client[:address_zipcode],
              delivery_address_street: client[:address_street],
              delivery_address_city: client[:address_city],
              purchase_order_number: project_version[:id].to_s
            )
          end
          # rubocop:enable RSpec/ExampleLength

          #
          it 'enqueues PDF generation job' do
            proforma = result.data

            expect(Accounting::FinancialTransactions::GenerateAndAttachPdfJob)
              .to have_received(:perform_async)
              .with({ "financial_transaction_id" => proforma.id })
          end
        end

        context 'when there is an error' do
          before do
            allow(Proforma).to receive(:create!).and_raise("Database error")
          end

          it { is_expected.to be_failure }

          it 'returns a failure result', :aggregate_failures do
            expect(result.error.message).to include("Database error")
          end
        end
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
