class Organization::FinancialYears::ExtendedDto < OpenApiDto
  field "id", :integer
  field "company_id", :integer
  field "start_date", :timestamp
  field "end_date", :timestamp
end
