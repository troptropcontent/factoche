class CreateOrganizationItemGroups < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_item_groups do |t|
      t.references :project_version, null: false, foreign_key: { to_table: :organization_project_versions }
      t.string :name

      t.timestamps
      t.index [ :name, :project_version_id ], unique: true
    end
  end
end
