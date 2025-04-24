module Accounting
  module FinancialTransactions
    class FindNextAvailableNumber
      include ApplicationService

      def call(company_id:, prefix:, issue_date: Time.current)
        raise ArgumentError, "Company ID is required" if company_id.blank?
        raise ArgumentError, "Prefix is required" if prefix.blank?

        base_prefix = "#{prefix}-#{issue_date.year}"

        last_financial_transaction = FinancialTransaction
          .where(company_id: company_id)
          .where(issue_date: issue_date.beginning_of_year..issue_date.end_of_year)
          .where("number LIKE ?", "#{base_prefix}%")
          .order(number: :desc).first

        last_financial_transaction_sequencial_identifier = last_financial_transaction ? last_financial_transaction.number.delete_prefix("#{base_prefix}-").to_i : 0

        new_number = [ prefix, issue_date.year, (last_financial_transaction_sequencial_identifier + 1).to_s.rjust(6, "0") ].join("-")

        new_number
      end
    end
  end
end
