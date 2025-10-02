module Accounting
  ClientSchema = Dry::Schema.Params do
    required(:id).filled(:integer)
    required(:vat_number).filled(:string)
    required(:name).filled(:string)
    required(:registration_number).filled(:string)
    required(:address_zipcode).filled(:string)
    required(:address_street).filled(:string)
    required(:address_city).filled(:string)
    required(:phone).filled(:string)
    required(:email).filled(:string)
  end
end
