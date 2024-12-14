FactoryBot.define do
  factory :organization_client, class: 'Organization::Client' do
    name { "Super Client" }
    registration_number { "123456" }
    email { "super@client.com" }
    phone { "+33612345645" }
    address_street { "15 rue des mouettes" }
    address_city { "Biarritz" }
    address_zipcode { "64200" }
  end
end
