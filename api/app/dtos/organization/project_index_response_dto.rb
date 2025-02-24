class Organization::ProjectIndexResponseProjectClientDto < OpenApiDto
  field "id", :integer
  field "name", :string
end

class Organization::ProjectIndexResponseProjectDto < OpenApiDto
  field "id", :integer
  field "name", :string
  field "description", :string, required: false
  field "client", :object, subtype: Organization::ProjectIndexResponseProjectClientDto
  field "last_version", :object, subtype: Organization::ProjectVersions::CompactDto
  field "status", :enum, subtype: [ "new", "invoicing_in_progress", "invoiced", "canceled" ]
end

class Organization::ProjectIndexResponseDto < OpenApiDto
  field "results", :array, subtype: Organization::ProjectIndexResponseProjectDto
end
