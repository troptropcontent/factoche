class Organization::ProjectDtoItemDto < OpenApiDto
  field name: :id, type: :integer
  field name: :position, type: :integer
  field name: :name, type: :string
  field name: :description, type: :string, required: false
  field name: :quantity, type: :integer
  field name: :unit, type: :string
  field name: :unit_price_cents, type: :integer
end

class Organization::ProjectDtoItemGroupDto < OpenApiDto
  field name: :id, type: :integer
  field name: :name, type: :string
  field name: :description, type: :string, required: false
  field name: :position, type: :integer
  field name: :items, type: :array, subtype: Organization::ProjectDtoItemDto
end

class Organization::ProjectDtoProjectVersionDto < OpenApiDto
  field name: :id, type: :integer
  field name: :retention_rate_guarantee, type: :integer
  field name: :number, type: :integer
  field name: :items, type: :array, subtype: [ [ Organization::ProjectDtoItemDto ],  [ Organization::ProjectDtoItemGroupDto ] ]
end

class Organization::ProjectDto < OpenApiDto
  field name: :id, type: :integer
  field name: :name, type: :string
  field name: :description, type: :string, required: false
  field name: :client_id, type: :integer
  field name: :versions, type: :array, subtype: Organization::ProjectDtoProjectVersionDto
end
