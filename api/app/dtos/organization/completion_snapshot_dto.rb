class Organization::CompletionSnapshotDtoItemDto < OpenApiDto
  field "completion_percentage", :decimal
  field "item_id", :integer
end

class Organization::CompletionSnapshotDto < OpenApiDto
  field "id", :integer
  field "created_at", :timestamp
  field "project_version", :object, subtype: Organization::ProjectVersions::CompactDto
  field "description", :string, required: false
  field "status", :enum, subtype: [ "draft", "cancelled", "published" ]
end
