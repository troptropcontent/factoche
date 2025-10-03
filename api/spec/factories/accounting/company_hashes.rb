# rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
FactoryBot.define do
  factory :accounting_company_hash, class: "Hash" do
    name  { "New Name" }
    registration_number  { "123456789" }
    address_zipcode  { "75001" }
    address_street  { "1 rue de la Paix" }
    address_city  { "Paris" }
    vat_number  { "FR123456789" }
    phone  { "+33123456789" }
    email  { "contact@acmecorp.com" }
    rcs_city  { "Paris" }
    rcs_number  { "RCS123456" }
    legal_form  { "sas" }
    capital_amount  { 10000 }
    config {
      {
        payment_term_days: 30,
        payment_term_accepted_methods: [ 'transfer' ],
        general_terms_and_conditions: '<h1>Condition<h1/>'
      }
    }
    bank_detail {
      {
        iban: 'IBAN',
        bic: 'BIC'
      }
    }

    skip_create
    initialize_with { attributes }
  end
end
# rubocop:enable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
