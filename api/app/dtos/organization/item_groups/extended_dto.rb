class Organization::ItemGroups::ExtendedDto < OpenApiDto
  field "id", :integer
  field "position", :integer
  field "name", :string
  field "description", :string, required: false
  field "grouped_items", :array, subtype: Organization::Items::ExtendedDto
end
