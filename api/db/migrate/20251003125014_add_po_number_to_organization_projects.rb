class AddPoNumberToOrganizationProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_projects, :po_number, :string
  end
end
