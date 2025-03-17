class AddTypeToOrganisationProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_projects, :type, :string
  end
end
