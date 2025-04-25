require 'rails_helper'
require 'support/shared_contexts/organization/projects/a_company_with_an_order'

module Accounting
  module FinancialTransactions
    RSpec.describe FindPrintUrl do
      describe '.call', :aggregate_failures do
        include_context 'a company with an order'

        let(:proforma) do
          ::Organization::Proformas::Create.call(
            order_version.id,
            invoice_amounts: [
              { original_item_uuid: order_version.items.first.original_item_uuid, invoice_amount: 1 },
              { original_item_uuid: order_version.items.second.original_item_uuid, invoice_amount: 2 }
            ]
          ).data
        end

        let(:invoice) { ::Accounting::Proformas::Post.call(proforma.id).data }
        let(:credit_note) { ::Accounting::Invoices::Cancel.call(invoice.id).data[:credit_note] }

        context 'when financial transaction is an invoice' do
          let(:financial_transaction_id) { invoice.id }

          it 'returns published invoice URL' do
            result = described_class.call(financial_transaction_id)

            expect(result).to be_success
            expect(result.data).to eq(
              Rails.application.routes.url_helpers.accounting_prints_published_invoice_url(
                invoice.id,
                host: ENV.fetch("PRINT_MICROSERVICE_HOST")
              )
            )
          end
        end

        context 'when financial transaction is a proforma' do
          let(:financial_transaction_id) { proforma.id }

          it 'returns unpublished invoice URL' do
            result = described_class.call(financial_transaction_id)

            expect(result).to be_success
            expect(result.data).to eq(
              Rails.application.routes.url_helpers.accounting_prints_unpublished_invoice_url(
                proforma.id,
                host: ENV.fetch("PRINT_MICROSERVICE_HOST")
              )
            )
          end
        end

        context 'when financial transaction is a credit note' do
          let(:financial_transaction_id) { credit_note.id }

          it 'returns credit note URL' do
            result = described_class.call(financial_transaction_id)

            expect(result).to be_success
            expect(result.data).to eq(
              Rails.application.routes.url_helpers.accounting_prints_credit_note_url(
                credit_note.id,
                host: ENV.fetch("PRINT_MICROSERVICE_HOST")
              )
            )
          end
        end

        context 'with invalid parameters' do
          context 'when financial_transaction_id is blank' do
            let(:financial_transaction_id) { nil }

            it 'returns failure' do
              result = described_class.call(financial_transaction_id)

              expect(result).to be_failure
              expect(result.error).to include("Financial transaction ID is required")
            end
          end
        end

        context 'when financial transaction is not found' do
          let(:financial_transaction_id) { -1 }

          it 'returns failure' do
            result = described_class.call(financial_transaction_id)

            expect(result).to be_failure
            expect(result.error).to include("Couldn't find Accounting::FinancialTransaction")
          end
        end

        context 'when financial transaction type is not supported' do
          before do
            allow(Accounting::FinancialTransaction).to receive(:find)
              .and_return(Accounting::FinancialTransaction.new)
          end

          let(:financial_transaction_id) { 1 }

          it 'returns failure' do
            result = described_class.call(financial_transaction_id)

            expect(result).to be_failure
            expect(result.error).to include("Unsupported financial transaction type")
          end
        end
      end
    end
  end
end
