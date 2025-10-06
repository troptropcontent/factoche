module Accounting
  ProjectSchema = Dry::Schema.Params do
    required(:name).filled(:string)
    required(:po_number).maybe(:string)
    required(:address_zipcode).filled(:string)
    required(:address_street).filled(:string)
    required(:address_city).filled(:string)
  end
end
