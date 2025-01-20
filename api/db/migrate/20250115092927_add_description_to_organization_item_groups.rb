class AddDescriptionToOrganizationItemGroups < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_item_groups, :description, :string
  end
end
