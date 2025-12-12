# rubocop:disable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
FactoryBot.define do
  factory :accounting_project_hash, class: "Hash" do
    name  { "Renovation HALL" }
    address_zipcode  { "75001" }
    address_street  { "1 rue de la Paix" }
    address_city  { "Paris" }
    po_number  { "PO_1234567" }
    previously_billed_amount  { "1000.0" }

    skip_create
    initialize_with { attributes }
  end
end
# rubocop:enable RSpec/EmptyExampleGroup, RSpec/MissingExampleGroupArgument
