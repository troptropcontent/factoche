class Organization::Clients::ExtendedDto < OpenApiDto
  field "id", :integer
  field "name", :string
  field "registration_number", :string, required: false
  field "vat_number", :string, required: false
  field "email", :string
  field "phone", :string
  field "address_street", :string
  field "address_city", :string
  field "address_zipcode", :string
end
