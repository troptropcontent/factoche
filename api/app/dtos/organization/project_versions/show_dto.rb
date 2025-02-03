class Organization::ProjectVersions::ShowDto < OpenApiDto
  field "result", :object, subtype: Organization::ProjectVersions::ExtendedDto
end
