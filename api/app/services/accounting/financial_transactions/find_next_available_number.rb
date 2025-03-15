module Accounting
  module FinancialTransactions
    class FindNextAvailableNumber
      class << self
        def call(company_id:, prefix:, issue_date: Time.current)
          raise ArgumentError, "Company ID is required" if company_id.blank?
          raise ArgumentError, "Prefix is required" if prefix.blank?

          transaction_count = FinancialTransaction
            .where(company_id: company_id)
            .where(issue_date: issue_date.beginning_of_year..issue_date.end_of_year)
            .where("number LIKE ?", "#{prefix}%")
            .count

          new_number = [ prefix, issue_date.year, (transaction_count + 1).to_s.rjust(6, "0") ].join("-")

          ServiceResult.success(new_number)
        rescue StandardError => e
          ServiceResult.failure("Failed to find next available number: #{e.message}")
        end
      end
    end
  end
end
