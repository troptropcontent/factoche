module Accounting
  module Invoices
    class FindNextAvailableNumber
      class << self
        def call(company_id:, published:, issue_date: Time.current)
          invoice_count = Invoice
            .where(company_id: company_id)
            .where(issue_date: issue_date.beginning_of_year..issue_date.end_of_year)
            .then { |invoices| published ? invoices.published : invoices.unpublished }
            .count

          prefix = published ? Invoice::NUMBER_PUBLISHED_PREFIX : Invoice::NUMBER_UNPUBLISHED_PREFIX

          new_number = [ prefix, issue_date.year, (invoice_count + 1).to_s.rjust(6, "0") ].join("-")

          ServiceResult.success(new_number)
        rescue StandardError => e
          ServiceResult.failure("Failed to find next available unpublished invoice number: #{e.message}")
        end
      end
    end
  end
end
