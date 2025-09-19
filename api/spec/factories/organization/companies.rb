FactoryBot.define do
  factory :company, class: 'Organization::Company' do
    name { "Company 1" }
    sequence(:registration_number) { |n| "REG#{n.to_s.rjust(9, '0')}" }
    sequence(:email) { |n| "company#{n}@example.com" }
    phone { "+33123456789" }
    address_city { "Biarritz" }
    address_street { "15 rue des mouettes" }
    address_zipcode { "64200" }
    rcs_city { "Biarritz" }
    rcs_number { "1234556" }
    vat_number { "123456" }
    capital_amount { 1000000.0 }

    trait :with_config do
      after(:create) { |company| create(:company_config, company: company) }
    end

    trait :with_bank_detail do
      after(:create) { |company| create(:bank_detail, company: company) }
    end
    trait :with_exercice do
      after(:create) { |company| create(:financial_year, company_id: company.id, start_date: Time.current.beginning_of_year, end_date: Time.current.end_of_year) }
    end
  end
end
