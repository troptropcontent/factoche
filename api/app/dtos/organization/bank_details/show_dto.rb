class Organization::BankDetails::ShowDto < OpenApiDto
  field "results", :array, subtype: Organization::BankDetails::ExtendedDto
end
