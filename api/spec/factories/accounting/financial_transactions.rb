# rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
FactoryBot.define do
  factory :financial_transaction, class: 'Accounting::FinancialTransaction' do
    company_id { nil }
    holder_id { nil }
    status { :draft }
    sequence(:number) { |n| status == :draft ? nil : "INV-2025-#{n.to_s.rjust(6, '0')}" }
    issue_date { Time.current }
  end
end
# rubocop:enable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
