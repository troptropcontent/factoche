FactoryBot.define do
  beginning_of_this_year = Time.current.beginning_of_year
  factory :accounting_financial_year, class: 'Accounting::FinancialYear' do
    start_date { beginning_of_this_year }
    end_date { beginning_of_this_year.end_of_year }
  end
end
