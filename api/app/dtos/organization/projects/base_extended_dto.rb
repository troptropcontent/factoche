module Organization
  module Projects
    class BaseExtendedDto < OpenApiDto
      field "id", :integer
      field "number", :integer
      field "name", :string
      field "description", :string, required: false
      field "client", :object, subtype: Organization::Clients::ExtendedDto
      field "bank_detail", :object, subtype: BankDetails::ExtendedDto
      field "last_version", :object, subtype: Organization::ProjectVersions::ExtendedDto
      field "address_street", :string
      field "address_zipcode", :string
      field "address_city", :string
    end
  end
end
