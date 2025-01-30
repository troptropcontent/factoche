class Organization::ProjectVersions::CompactDto < OpenApiDto
  field "id", :integer
  field "number", :integer
  field "created_at", :timestamp
  field "retention_guarantee_rate", :integer
end
