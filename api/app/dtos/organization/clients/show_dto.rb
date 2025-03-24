class Organization::Clients::ShowDto < OpenApiDto
  field "result", :object, subtype: Organization::Clients::ExtendedDto
end
