class Organization::CompletionSnapshots::CompactDto < OpenApiDto
  field "id", :integer
  field "description", :string, required: false
  field "status", :enum, subtype: [ "draft", "cancelled", "published" ]
  field "project_version", :object, subtype: Organization::ProjectVersions::CompactDto
  field "created_at", :timestamp
end
