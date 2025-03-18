module Organization
  module Projects
    class ExtendedDto < OpenApiDto
      field "id", :integer
      field "name", :string
      field "description", :string, required: false
      field "client", :object, subtype: Organization::Clients::ExtendedDto
      field "invoiced_amount", :decimal
      field "last_version", :object, subtype: Organization::ProjectVersions::ExtendedDto
      field "status", :enum, subtype: [ "new", "invoicing_in_progress", "invoiced", "canceled" ]
    end
  end
end
