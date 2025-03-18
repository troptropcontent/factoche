class Organization::ProjectDtoItemDto < OpenApiDto
  field "id", :integer
  field "position", :integer
  field "name", :string
  field "description", :string, required: false
  field "quantity", :integer
  field "unit", :string
  field "unit_price_amount", :decimal
end

class Organization::ProjectDtoItemGroupDto < OpenApiDto
  field "id", :integer
  field "name", :string
  field "description", :string, required: false
  field "position", :integer
  field "items", :array, subtype: Organization::ProjectDtoItemDto
end

class Organization::ProjectDtoProjectVersionDto < OpenApiDto
  field "id", :integer
  field "retention_rate_guarantee", :integer
  field "number", :integer
  field "items", :array, subtype: [ [ Organization::ProjectDtoItemDto ],  [ Organization::ProjectDtoItemGroupDto ] ]
end

class Organization::ProjectDto < OpenApiDto
  field "id", :integer
  field "name", :string
  field "description", :string, required: false
  field "client_id", :integer
  field "versions", :array, subtype: Organization::ProjectDtoProjectVersionDto
end
