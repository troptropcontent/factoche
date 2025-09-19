module Accounting
  module FinancialTransactions
    class FindNextAvailableNumber
      include ApplicationService

      def call(company_id:, financial_year_id:, prefix:, issue_date: Time.current)
        raise ArgumentError, "Company ID is required" if company_id.blank?
        raise ArgumentError, "Prefix is required" if prefix.blank?
        raise ArgumentError, "Financial Year ID required" if financial_year_id.blank?

        financial_year = Accounting::FinancialYear.find(financial_year_id)

        base_prefix = "#{prefix}-#{financial_year.start_date.year}"

        month_identifier = issue_date.month.to_s.rjust(2, "0")

        last_financial_transaction = FinancialTransaction
          .where(company_id: company_id, financial_year_id: financial_year_id)
          .where("number LIKE ?", "#{base_prefix}%")
          .order(
            Arel.sql("SPLIT_PART(number, '-', 4)::INTEGER DESC")
          ).limit(1).first

        last_financial_transaction_sequencial_identifier = last_financial_transaction ? last_financial_transaction.number.split("-")[-1].to_i : 0

        new_number = [ prefix, financial_year.start_date.year, month_identifier, (last_financial_transaction_sequencial_identifier + 1).to_s.rjust(6, "0") ].join("-")

        new_number
      end
    end
  end
end
