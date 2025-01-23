class CreateOrganizationCompletionSnapshots < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_completion_snapshots do |t|
      t.references :project_version, null: false, foreign_key: { to_table: "organization_project_versions" }
      t.string :description

      t.timestamps
    end
  end
end
