class Organization::CompletionSnapshots::CompactDto < OpenApiDto
  field "id", :integer
  field "status", :enum, subtype: [ "draft", "cancelled", "invoiced" ]
  field "created_at", :timestamp
end
