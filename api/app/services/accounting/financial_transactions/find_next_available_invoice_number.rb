module Accounting
  module FinancialTransactions
    class FindNextAvailableInvoiceNumber
      INVOICE_PREFIX = "INV".freeze
      class << self
        def call(company_id, issue_date = Time.current)
          invoice_count = FinancialTransaction.where("type LIKE '%Invoice' AND company_id = ? AND status = ?", company_id, :posted).count

          new_number = [ INVOICE_PREFIX, issue_date.year, (invoice_count + 1).to_s.rjust(6, "0") ].join("-")
          # TODO: Implement logic to find next available invoice number
          ServiceResult.success(new_number)
        rescue StandardError => e
          ServiceResult.failure("Failed to find next available invoice number: #{e.message}")
        end
      end
    end
  end
end
