require 'rails_helper'

module Accounting
  module FinancialTransactions
    # rubocop:disable RSpec/MultipleMemoizedHelpers
    RSpec.describe UpdateInvoice do
      describe '.call' do
        subject(:result) { described_class.call(invoice_id, company, client, project_version, new_invoice_items, issue_date) }
        let(:invoice_id) { original_invoice.id }
        let(:issue_date) { Time.current }
        let(:company_id) { 1 }
        let(:new_invoice_items) { [ {
          original_item_uuid: first_item_uuid,
          invoice_amount: "125.23"
        } ] }
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
          config: {
            payment_term: {
              days: 30,
              accepted_methods: [ "transfer" ]
            }
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
          CreateCompletionSnapshotInvoice.call(company.merge({ name: "OLD NAME" }), client.merge({ name: "OLD Client NAME" }), project_version, [ {
          original_item_uuid: first_item_uuid,
          invoice_amount: 50
        } ]).data}

        context 'when successful' do
          # rubocop:disable RSpec/ExampleLength

          it { is_expected.to be_success }

          it 'updates the invoice and its details', :aggregate_failures do
            expect { result }.to change { Accounting::CompletionSnapshotInvoice.find(original_invoice.id).detail.seller_name }.from("OLD NAME").to("New Name")
          end
          # rubocop:enable RSpec/ExampleLength

          it 'destroy and recreates the relevant invoice lines', :aggregate_failures do
            invoice = result.data

            expect(invoice.lines.count).to eq(1)
            expect(invoice.lines.first.excl_tax_amount).to eq('125.23'.to_d)

            expect(invoice.lines.first.quantity).to eq("1.2523".to_d) # 125 € (invoice amount) / 100 € (unit price) => the proportional quantity required to reach the amount invoiced
          end

          # rubocop:disable RSpec/ExampleLength
          it 'update the invoice detail', :aggregate_failures do
            invoice = result.data

            expect(invoice.detail).to be_present
            expect(invoice.detail).to have_attributes(
              delivery_date: be_within(1.second).of(issue_date),
              due_date: be_within(1.second).of(issue_date + 30.days),
              seller_name: company[:name],
              seller_registration_number: company[:registration_number],
              seller_address_zipcode: company[:address_zipcode],
              seller_address_street: company[:address_street],
              seller_address_city: company[:address_city],
              seller_vat_number: company[:vat_number],
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
        end

        context 'when there is an error' do
          before do
            allow(BuildCompletionSnapshotInvoiceAttributes).to receive(:call).and_return(ServiceResult.failure("Aoutch"))
          end

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
