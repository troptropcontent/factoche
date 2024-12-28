class CreateOrganizationProjectVersions < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_project_versions do |t|
      t.references :project, null: false, foreign_key: { to_table: "organization_projects" }
      t.integer :number, default: 1, null: false

      t.timestamps
    end
  end
end
