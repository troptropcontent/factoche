class Organization::CompletionSnapshots::IndexDto < OpenApiDto
  field "results", :array, subtype: Organization::CompletionSnapshots::CompactDto
end
