class Organization::CompletionSnapshotDtoItemDto < OpenApiDto
  field "completion_percentage", :decimal
  field "item_id", :integer
end

class Organization::CompletionSnapshotDto < OpenApiDto
  field "id", :integer
  field "project_version_id", :integer
  field "description", :string, required: false
  field "completion_snapshot_items", :array, subtype: Organization::CompletionSnapshotDtoItemDto
end
