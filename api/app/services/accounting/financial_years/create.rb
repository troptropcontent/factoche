module Accounting
  module FinancialYears
    class Create
      include ApplicationService

      def call(company_id:, start_date:, end_date:)
        Accounting::FinancialYear.create!(
          company_id: company_id,
          start_date: start_date,
          end_date: end_date
        )
      end
    end
  end
end
