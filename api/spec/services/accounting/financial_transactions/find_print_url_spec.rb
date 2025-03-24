require 'rails_helper'

module Accounting
  module FinancialTransactions
    RSpec.describe FindPrintUrl do
      describe '.call', :aggregate_failures do
        let(:invoice) { FactoryBot.create(:invoice, company_id: 1, holder_id: 1, number: "PRO-2024-00001") }

        context 'when financial transaction is an invoice' do
          let(:financial_transaction_id) { invoice.id }

          context 'with draft status' do
            it 'returns unpublished invoice URL' do
              result = described_class.call(financial_transaction_id)

              expect(result).to be_success
              expect(result.data).to eq(
                Rails.application.routes.url_helpers.accounting_prints_unpublished_invoice_url(
                  invoice.id,
                  { host: ENV.fetch("PRINT_MICROSERVICE_HOST"), port: ENV.fetch("PRINT_MICROSERVICE_PORT") }
                )
              )
            end
          end

          context 'with posted status' do
            before { invoice.update!(status: :posted, number: 'INV-2024-0001') }

            it 'returns published invoice URL' do
              result = described_class.call(financial_transaction_id)

              expect(result).to be_success
              expect(result.data).to eq(
                Rails.application.routes.url_helpers.accounting_prints_published_invoice_url(
                  invoice.id,
                  { host: ENV.fetch("PRINT_MICROSERVICE_HOST"), port: ENV.fetch("PRINT_MICROSERVICE_PORT") }
                )
              )
            end
          end
        end

        context 'when financial transaction is a credit note' do
          let(:credit_note) { FactoryBot.create(:credit_note, company_id: 1, holder_id: invoice.id, number: "CN-2024-00001") }
          let(:financial_transaction_id) { credit_note.id }

          it 'returns credit note URL' do
            result = described_class.call(financial_transaction_id)

            expect(result).to be_success
            expect(result.data).to eq(
              Rails.application.routes.url_helpers.accounting_prints_credit_note_url(
                credit_note.id,
                { host: ENV.fetch("PRINT_MICROSERVICE_HOST"), port: ENV.fetch("PRINT_MICROSERVICE_PORT") }
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
