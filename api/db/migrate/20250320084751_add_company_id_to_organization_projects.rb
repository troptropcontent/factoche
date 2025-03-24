class AddCompanyIdToOrganizationProjects < ActiveRecord::Migration[8.0]
  def change
    add_reference :organization_projects, :company, null: false, foreign_key: { to_table: "organization_companies" }
    add_column :organization_projects, :number, :integer, null: false
    add_index :organization_projects, [ :company_id, :type, :number ], unique: true
  end
end
