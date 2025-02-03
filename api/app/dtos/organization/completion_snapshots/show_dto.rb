class Organization::CompletionSnapshots::ShowDto < OpenApiDto
  field "result", :object, subtype: Organization::CompletionSnapshots::ExtendedDto
end
