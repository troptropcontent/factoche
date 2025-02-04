class Organization::CompletionSnapshots::ExtendedDto < OpenApiDto
  field "id", :integer
  field "status", :enum, subtype: [ "draft", "cancelled", "invoiced" ]
  field "project_version", :object, subtype: Organization::ProjectVersions::ExtendedDto
  field "completion_snapshot_items", :array, subtype: Organization::CompletionSnapshotItems::ExtendedDto
  field "created_at", :timestamp
end
