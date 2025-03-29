module Organization
  module Companies
    class ExtendedDto < OpenApiDto
        field "id", :integer
        field "name", :string
        field "registration_number", :string
        field "email", :string
        field "phone", :string
        field "address_city", :string
        field "address_street", :string
        field "address_zipcode", :string
        field "legal_form", :enum, subtype: Organization::Company.legal_forms.values
        field "rcs_city", :string
        field "rcs_number", :string
        field "vat_number", :string
        field "capital_amount", :decimal
        field "config", :object, subtype: CompanyConfigs::ExtendedDto
    end
  end
end
