class Organization::ShowCompletionSnapshotResponseDto < OpenApiDto
  field "result", :object, subtype: Organization::CompletionSnapshots::ExtendedDto
end
