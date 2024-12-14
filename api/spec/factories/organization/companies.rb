FactoryBot.define do
  factory :organization_company, class: 'Organization::Company' do
    name { "My company" }
    registration_number { "123456789" }
    email { "mycompany@example.com" }
    phone { "+33123456789" }
    address_city { "15 rue des mouettes" }
    address_street { "Biarritz" }
    address_zipcode { "64200" }
  end
end
