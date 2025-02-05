class Organization::CompletionSnapshots::PreviousDto < OpenApiDto
  field "result", :object, subtype: Organization::CompletionSnapshots::ExtendedDto, required: false
end
