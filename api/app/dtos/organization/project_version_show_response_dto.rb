class Organization::ProjectVersionShowProjectVersionItemDto < OpenApiDto
  field "id", :integer
  field "position", :integer
  field "name", :string
  field "description", :string, required: false
  field "quantity", :integer
  field "unit", :string
  field "unit_price_cents", :integer
end

class Organization::ProjectVersionShowProjectVersionItemGroupDto < OpenApiDto
  field "id", :integer
  field "position", :integer
  field "name", :string
  field "description", :string, required: false
  field "grouped_items", :array, subtype: Organization::ProjectVersionShowProjectVersionItemDto
end

class Organization::ProjectVersionShowResponseProjectVersionDto < OpenApiDto
  field "id", :integer
  field "number", :integer
  field "created_at", :timestamp
  field "retention_guarantee_rate", :integer
  field "ungrouped_items", :array, subtype: Organization::ProjectVersionShowProjectVersionItemDto
  field "item_groups", :array, subtype: Organization::ProjectVersionShowProjectVersionItemGroupDto
end

class Organization::ProjectVersionShowResponseDto < OpenApiDto
  field "result", :object, subtype: Organization::ProjectVersionShowResponseProjectVersionDto
end
