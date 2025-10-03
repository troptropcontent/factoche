# rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
FactoryBot.define do
  factory :accounting_client_hash, class: "Hash" do
    name { 'Client Corp' }
    registration_number { '987654321' }
    address_zipcode { '54321' }
    address_street { '456 Client St' }
    address_city { 'Client City' }
    vat_number { 'VAT987654' }
    phone { '+33123456789' }
    email { 'contact@clientcorp.com' }

    skip_create
    initialize_with { attributes }
  end
end
# rubocop:enable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
