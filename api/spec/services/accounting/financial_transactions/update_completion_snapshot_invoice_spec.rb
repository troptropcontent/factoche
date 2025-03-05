require 'rails_helper'

module Accounting
  module FinancialTransactions
    # rubocop:disable RSpec/MultipleMemoizedHelpers
    RSpec.describe UpdateCompletionSnapshotInvoice do
      describe '.call' do
        subject(:result) { described_class.call(invoice.id, company, client, project_version, new_invoice_items, issue_date) }
        let!(:invoice) { CreateCompletionSnapshotInvoice.call(company, client, project_version, previous_invoice_items).data }
        let(:previous_invoice_items) { [ {
          original_item_uuid: "item-1",
          invoice_amount: 10
        } ] }
        let(:project_version) do
          {
            id: 1,
            number: 1,
            created_at: 1.day.ago,
            retention_guarantee_rate: "0.05",
            items: [
              {
                original_item_uuid: "item-1",
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
          id: 1,
          name: "ACME Corp",
          registration_number: "123456789",
          address_zipcode: "75001",
          address_street: "1 rue de la Paix",
          address_city: "Paris",
          vat_number: "FR123456789",
          config: {
            "payment_term" => {
              "days" => 30,
              "accepted_methods" => [ "transfer" ]
            }
          }
        } }

        let(:client) { {
          name: "Client Corp",
          registration_number: "987654321",
          address_zipcode: "75002",
          address_street: "2 avenue des Champs-Élysées",
          address_city: "Paris",
          vat_number: "FR987654321"
        } }

        let(:issue_date) { Time.current }

        let(:new_invoice_items) { [ {
          original_item_uuid: "item-1",
          invoice_amount: 125
        } ] }


        context 'when invoice is in draft status' do
          it "returns a success" do
            expect(result).to be_success
          end


          it 'updates the invoice successfully', :aggregate_failures do
            invoice.update(issue_date: 2.days.ago)
            expect { result }.to change { invoice.reload.issue_date }
          end

          it 'destroys existing lines and creates new ones' do
            expect { result }.to change { invoice.lines.first.excl_tax_amount }.from(10.to_d).to(125.to_d)
          end

          it 'updates invoice details' do
            invoice.detail.update(seller_name: "Old Company Name")
            expect { result }.to change { invoice.reload.detail.seller_name }.from("Old Company Name").to("ACME Corp")
          end
        end

        context 'when invoice is not in draft status' do
          before do
            invoice.update!(status: 'posted', number: "INV-2025-0001")
          end

          it { is_expected.to be_failure }

          it 'returns failure result' do
            expect(result.error).to include('Cannot update invoice that is not in draft status')
          end
        end

        context 'when invoice attributes builder fails' do
          before do
            allow(BuildCompletionSnapshotInvoiceAttributes)
              .to receive(:call)
              .and_return(ServiceResult.failure('Failed to build invoice attributes'))
          end

          it { is_expected.to be_failure }

          it 'returns failure result' do
            expect(result.error).to include('Failed to build invoice attributes')
          end
        end

        context 'when invoice detail attributes builder fails' do
          before do
            allow(BuildCompletionSnapshotInvoiceDetailAttributes)
              .to receive(:call)
              .and_return(ServiceResult.failure('Failed to build detail attributes'))
          end

          it { is_expected.to be_failure }

          it 'returns failure result' do
            expect(result.error).to include('Failed to build detail attributes')
          end
        end
      end
    end
    # rubocop:enable RSpec/MultipleMemoizedHelpers
  end
end
