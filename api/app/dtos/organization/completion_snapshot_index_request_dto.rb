class Organization::CompletionSnapshotIndexRequestDto < OpenApiDto
  field "company_id", :integer, required: false
  field "project_id", :integer, required: false
  field "project_version_id", :integer, required: false
end
