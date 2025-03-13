module Accounting
  module Invoices
    class FindNextAvailableUnpublishedNumber
      class << self
        def call(company_id, issue_date = Time.current)
          unpublished_invoice_count = Invoice.unpublished
            .where(company_id: company_id)
            .where(issue_date: issue_date.beginning_of_year..issue_date.end_of_year)
            .count

          new_number = [ Invoice::NUMBER_UNPUBLISHED_PREFIX, issue_date.year, (unpublished_invoice_count + 1).to_s.rjust(6, "0") ].join("-")

          ServiceResult.success(new_number)
        rescue StandardError => e
          ServiceResult.failure("Failed to find next available unpublished invoice number: #{e.message}")
        end
      end
    end
  end
end
