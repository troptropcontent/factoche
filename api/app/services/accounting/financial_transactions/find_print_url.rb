module Accounting
  module FinancialTransactions
    class FindPrintUrl
      class << self
        def call(financial_transaction_id)
          raise ArgumentError, "Financial transaction ID is required" if financial_transaction_id.blank?

          financial_transaction = FinancialTransaction.find(financial_transaction_id)
          route_args = [ financial_transaction.id, { host: ENV.fetch("FABATI_PRINT_MICROSERVICE_HOST"), port: ENV.fetch("FABATI_PRINT_MICROSERVICE_PORT") } ]

          url = case financial_transaction
          when CreditNote
            find_credit_note_url(*route_args)
          when Invoice
            find_invoice_url(financial_transaction, *route_args)
          else
            raise Error::UnprocessableEntityError, "Unsupported financial transaction type"
          end

          ServiceResult.success(url)
        rescue StandardError => e
          ServiceResult.failure("Failed to find print URL: #{e.message}")
        end

        private

        def find_credit_note_url(*route_args)
          Rails.application.routes.url_helpers.accounting_prints_credit_note_url(*route_args)
        end

        def find_invoice_url(invoice, *route_args)
          if Invoice::PUBLISHED_STATUS.include?(invoice.status)
            Rails.application.routes.url_helpers.accounting_prints_published_invoice_url(*route_args)
          else
            Rails.application.routes.url_helpers.accounting_prints_unpublished_invoice_url(*route_args)
          end
        end
      end
    end
  end
end
