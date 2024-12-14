FactoryBot.define do
  factory :organization_company, class: 'Organization::Company' do
    name { "MyString" }
    registration_number { "MyString" }
    email { "MyString" }
    phone { "MyString" }
    address_city { "MyString" }
    address_street { "MyString" }
    address_zipcode { "MyString" }
  end
end
