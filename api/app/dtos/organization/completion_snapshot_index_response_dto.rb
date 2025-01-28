class Organization::CompletionSnapshotIndexResponseDto < OpenApiDto
  field "results", :array, subtype: Organization::CompletionSnapshotDto
end
