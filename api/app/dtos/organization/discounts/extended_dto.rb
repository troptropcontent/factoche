class Organization::Discounts::ExtendedDto < OpenApiDto
  field "id", :integer
  field "original_discount_uuid", :string
  field "position", :integer
  field "kind", :enum, subtype: [ "percentage", "fixed_amount" ]
  field "value", :decimal
  field "amount", :decimal
  field "name", :string
end
