class Organization::ProjectVersions::ExtendedDto < OpenApiDto
  field "id", :integer
  field "number", :integer
  field "created_at", :timestamp
  field "retention_guarantee_rate", :decimal
  field "total_excl_tax_amount", :decimal
  field "ungrouped_items", :array, subtype: Organization::Items::ExtendedDto
  field "item_groups", :array, subtype: Organization::ItemGroups::ExtendedDto
  field "discounts", :array, subtype: Organization::Discounts::ExtendedDto
  field "project_id", :integer
  field "items", :array, subtype: Organization::Items::ExtendedDto
  field "pdf_url", :string, required: false
end
