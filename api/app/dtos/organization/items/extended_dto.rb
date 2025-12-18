class Organization::Items::ExtendedDto < OpenApiDto
  field "id", :integer
  field "original_item_uuid", :string
  field "position", :integer
  field "name", :string
  field "description", :string, required: false
  field "quantity", :decimal
  field "unit", :string
  field "unit_price_amount", :decimal
  field "item_group_id", :integer, required: false
  field "tax_rate", :decimal
end
