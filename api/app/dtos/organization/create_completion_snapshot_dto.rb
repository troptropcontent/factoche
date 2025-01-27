class Organization::CreateCompletionSnapshotItemDto < OpenApiDto
  field "completion_percentage", :string
  field "item_id", :integer
end

class Organization::CreateCompletionSnapshotDto < OpenApiDto
  field "description", :string, required: false
  field "completion_snapshot_items", :array, subtype: Organization::CreateCompletionSnapshotItemDto
end
