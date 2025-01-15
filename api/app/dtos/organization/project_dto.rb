class Organization::ItemDto < OpenApiDto
  field name: :position, type: :integer
  field name: :name, type: :string
  field name: :description, type: :string, required: false
  field name: :quantity, type: :integer
  field name: :unit, type: :string
  field name: :unit_price_cents, type: :integer
end

class Organization::ItemGroupDto < OpenApiDto
  field name: :name, type: :string
  field name: :description, type: :string, required: false
  field name: :position, type: :integer
  field name: :items, type: :array, subtype: Organization::ItemDto
end

class Organization::ProjectDto < OpenApiDto
  field name: :name, type: :string
  field name: :client_id, type: :integer
  field name: :retention_guarantee_rate, type: :integer
  field name: :items, type: :array, subtype: [ Organization::ItemDto, Organization::ItemGroupDto ]
end
