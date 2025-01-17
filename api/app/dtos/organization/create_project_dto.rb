class Organization::CreateProjecItemDto < OpenApiDto
  field name: :name, type: :string
  field name: :description, type: :string, required: false
  field name: :position, type: :integer
  field name: :unit, type: :string
  field name: :unit_price_cents, type: :integer
  field name: :quantity, type: :integer
end

class Organization::CreateProjectItemGroupDto < OpenApiDto
  field name: :name, type: :string
  field name: :description, type: :string, required: false
  field name: :position, type: :integer
  field name: :items, type: :array, subtype: Organization::CreateProjecItemDto
end

class Organization::CreateProjectDto < OpenApiDto
  field name: :name, type: :string
  field name: :description, type: :string, required: false
  field name: :client_id, type: :integer
  field name: :retention_guarantee_rate, type: :integer
  field name: :items, type: :array, subtype: [ [ Organization::CreateProjecItemDto ], [ Organization::CreateProjectItemGroupDto ] ]
end
