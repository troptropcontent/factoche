module Accounting
  module FinancialTransactions
    class PostCompletionSnapshotInvoice
      class << self
        def call(invoice_id, issue_date = Time.current)
          invoice = Accounting::CompletionSnapshotInvoice.find(invoice_id)

          ensure_invoice_is_draft!(invoice)

          next_available_number = find_next_available_invoice_number!(invoice.company_id, issue_date)

          invoice.update!(status: :posted, number: next_available_number)

          # TODO : Trigger the background job that will generate the invoice pdf here

          ServiceResult.success(invoice)
        rescue StandardError => e
          ServiceResult.failure("Failed to post invoice: #{e.message}")
        end

        private

        def ensure_invoice_is_draft!(invoice)
          unless invoice.status == "draft"
            raise ArgumentError, "Cannot post invoice that is not in draft status"
          end
        end

        def find_next_available_invoice_number!(company_id, issue_date)
          result = FindNextAvailableInvoiceNumber.call(company_id, issue_date)
          raise result.error unless result.success?
          result.data
        end
      end
    end
  end
end
