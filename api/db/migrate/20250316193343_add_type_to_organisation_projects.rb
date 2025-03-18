class AddTypeToOrganisationProjects < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_projects, :type, :string

    remove_index :organization_projects, name: "index_organization_projects_on_name_and_client_id"
    add_index :organization_projects, [ :name, :client_id, :type ], unique: true
  end
end
