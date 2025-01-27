class Organization::ShowCompletionSnapshotResponseDto < OpenApiDto
  field "result", :object, subtype: Organization::CompletionSnapshotDto
end
