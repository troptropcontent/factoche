FactoryBot.define do
  factory :client, class: 'Organization::Client' do
    name { "Super Client" }
    sequence(:registration_number) { |n| "REG#{n.to_s.rjust(9, '0')}" }
    sequence(:vat_number) { |n| "VAT#{n.to_s.rjust(9, '0')}" }
    email { "super@client.com" }
    phone { "+33612345645" }
    address_street { "15 rue des mouettes" }
    address_city { "Biarritz" }
    address_zipcode { "64200" }
  end
end
