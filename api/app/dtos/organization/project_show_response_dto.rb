class Organization::ProjectShowResponseProjectClientDto < OpenApiDto
  field "id", :integer
  field "name", :string
  field "email", :string
  field "phone", :string
end

class Organization::ProjectShowResponseProjectItemDto < OpenApiDto
  field "id", :integer
  field "original_item_uuid", :string
  field "position", :integer
  field "name", :string
  field "description", :string, required: false
  field "quantity", :integer
  field "unit", :string
  field "unit_price_cents", :integer
end

class Organization::ProjectShowResponseProjectItemGroupDto < OpenApiDto
  field "id", :integer
  field "position", :integer
  field "name", :string
  field "description", :string, required: false
  field "grouped_items", :array, subtype: Organization::ProjectShowResponseProjectItemDto
end

class Organization::ProjectShowResponseProjectLastVersionDto < OpenApiDto
  field "id", :integer
  field "number", :integer
  field "created_at", :timestamp
  field "completion_snapshots", :array, subtype: Organization::CompletionSnapshots::CompactDto
  field "ungrouped_items", :array, subtype: Organization::ProjectShowResponseProjectItemDto
  field "item_groups", :array, subtype: Organization::ProjectShowResponseProjectItemGroupDto
end

class Organization::ProjectShowResponseProjectDto < OpenApiDto
  field "id", :integer
  field "name", :string
  field "description", :string, required: false
  field "client", :object, subtype: Organization::ProjectShowResponseProjectClientDto
  field "status", :enum, subtype: [ "new", "invoicing_in_progress", "invoiced", "canceled" ]
  field "last_version", :object, subtype: Organization::ProjectShowResponseProjectLastVersionDto
end

class Organization::ProjectShowResponseDto < OpenApiDto
  field "result", :object, subtype: Organization::ProjectShowResponseProjectDto
end
