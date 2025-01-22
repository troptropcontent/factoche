class Organization::ProjectVersionIndexResponseProjectDto < OpenApiDto
  field "id", :integer
  field "number", :integer
  field "created_at", :timestamp
end

class Organization::ProjectVersionIndexResponseDto < OpenApiDto
  field "results", :array, subtype: Organization::ProjectVersionIndexResponseProjectDto
end
