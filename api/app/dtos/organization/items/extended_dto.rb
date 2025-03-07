class Organization::Items::ExtendedDto < OpenApiDto
  field "id", :integer
  field "original_item_uuid", :string
  field "position", :integer
  field "name", :string
  field "description", :string, required: false
  field "quantity", :integer
  field "unit", :string
  field "unit_price_cents", :integer
  field "item_group_id", :integer, required: false
end
