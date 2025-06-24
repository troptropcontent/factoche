module Accounting
  module FinancialTransactions
    class FindPrintUrl
      include ApplicationService


      def call(financial_transaction_id)
        raise ArgumentError, "Financial transaction ID is required" if financial_transaction_id.blank?

        financial_transaction = FinancialTransaction.find(financial_transaction_id)
        host = ENV.fetch("PRINT_MICROSERVICE_HOST")
        token = JwtAuth.generate_token(0, ENV.fetch("PRINT_TOKEN_SECRET"), 1.hours)

        route_args = [ financial_transaction.id, { host: host, params:  { token: token } } ]

        url = case financial_transaction
        when CreditNote
          find_credit_note_url(*route_args)
        when Invoice
          find_invoice_url(*route_args)
        when Proforma
          find_proforma_url(*route_args)
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

      def find_invoice_url(*route_args)
        Rails.application.routes.url_helpers.accounting_prints_published_invoice_url(*route_args)
      end

      def find_proforma_url(*route_args)
        Rails.application.routes.url_helpers.accounting_prints_unpublished_invoice_url(*route_args)
      end
    end
  end
end
