FactoryBot.define do
  factory :company, class: 'Organization::Company' do
    name { "Company 1" }
    sequence(:registration_number) { |n| "REG#{n.to_s.rjust(9, '0')}" }
    sequence(:email) { |n| "company#{n}@example.com" }
    phone { "+33123456789" }
    address_city { "Biarritz" }
    address_street { "15 rue des mouettes" }
    address_zipcode { "64200" }
  end
end
