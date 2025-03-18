class Organization::CreateProjecItemDto < OpenApiDto
  field  "name", :string
  field  "description", :string, required: false
  field  "position", :integer
  field  "unit", :string
  field  "unit_price_amount", :decimal
  field  "quantity", :integer
end

class Organization::CreateProjectItemGroupDto < OpenApiDto
  field  "name", :string
  field  "description", :string, required: false
  field  "position", :integer
  field  "items", :array, subtype: Organization::CreateProjecItemDto
end

class Organization::CreateProjectDto < OpenApiDto
  field  "name", :string
  field  "description", :string, required: false
  field  "client_id", :integer
  field  "retention_guarantee_rate", :integer
  field  "items", :array, subtype: [ [ Organization::CreateProjecItemDto ], [ Organization::CreateProjectItemGroupDto ] ]
end
