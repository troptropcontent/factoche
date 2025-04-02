module Organization
  module Projects
    class BaseCompactDto < OpenApiDto
      field "id", :integer
      field "number", :integer
      field "name", :string
      field "description", :string, required: false
      field "client", :object, subtype: Organization::Clients::ExtendedDto
      field "last_version", :object, subtype: Organization::ProjectVersions::CompactDto
    end
  end
end
