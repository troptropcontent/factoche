module Organization
  module Projects
    class BaseCompactDto < OpenApiDto
      field "id", :integer
      field "name", :string
      field "description", :string, required: false
      field "client", :object, subtype: Organization::Clients::ExtendedDto
      field "last_version", :object, subtype: Organization::ProjectVersions::CompactDto
      field "status", :enum, subtype: [ "new", "invoicing_in_progress", "invoiced", "canceled" ]
    end
  end
end
