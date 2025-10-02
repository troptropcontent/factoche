module Accounting
  module FinancialYears
    class Renew
      include ApplicationService

      def call(financial_year_id)
        financial_year = Accounting::FinancialYear.find(financial_year_id)


        Accounting::FinancialYear.create!(
          company_id: financial_year.company_id,
          start_date: financial_year.start_date.next_year,
          end_date: financial_year.end_date.next_year.end_of_month,
        )
      end
    end
  end
end
