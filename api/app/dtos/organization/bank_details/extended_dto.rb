module Organization
  module BankDetails
    class ExtendedDto < OpenApiDto
        field "id", :integer
        field "name", :string
        field "iban", :string
        field "bic", :string
    end
  end
end
