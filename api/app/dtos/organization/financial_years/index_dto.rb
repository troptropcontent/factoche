class Organization::FinancialYears::IndexDto < OpenApiDto
  field "results", :array, subtype: Organization::FinancialYears::ExtendedDto
end
