class Organization::CompletionSnapshots::UpdatableCompletionSnapshotItem < OpenApiDto
  field "completion_percentage", :string
  field "item_id", :integer
end

# This DTO represents the data structure for updating a completion snapshot:
# - description: Optional string describing the snapshot
# - completion_snapshot_items: Array of items with:
#   - id: Optional integer for existing items
#   - completion_percentage: String representing completion %
#   - item_id: Integer reference to the associated item
class Organization::CompletionSnapshots::UpdateDto < OpenApiDto
  field "description", :string, required: false
  field "completion_snapshot_items", :array, subtype: Organization::CompletionSnapshots::UpdatableCompletionSnapshotItem
end
