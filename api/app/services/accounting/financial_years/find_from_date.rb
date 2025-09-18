module Accounting
  module FinancialYears
    class FindFromDate
      include ApplicationService

      def call(company_id, issue_date)
        financial_year = Accounting::FinancialYear.find_by(
            company_id: company_id,
            start_date: ..issue_date,
            end_date: issue_date..
        )

        raise ArgumentError, "No financial year found for company #{company_id} and date #{issue_date}" unless financial_year

        financial_year
      end
    end
  end
end
