class Organization::FinancialYears::ShowDto < OpenApiDto
  field "result", :object, subtype: Organization::FinancialYears::ExtendedDto
end
