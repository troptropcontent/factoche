module Accounting
  ClientSchema = Dry::Schema.Params do
    required(:id).filled(:integer)
    required(:name).filled(:string)
    required(:address_zipcode).filled(:string)
    required(:address_street).filled(:string)
    required(:address_city).filled(:string)
    required(:phone).filled(:string)
    required(:email).filled(:string)
    required(:vat_number).maybe(:string)
    required(:registration_number).maybe(:string)
  end
end
