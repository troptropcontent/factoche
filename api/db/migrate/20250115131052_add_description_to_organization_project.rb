class AddDescriptionToOrganizationProject < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_projects, :description, :string
  end
end
