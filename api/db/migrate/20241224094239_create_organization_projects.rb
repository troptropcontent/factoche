class CreateOrganizationProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_projects do |t|
      t.references :client, null: false, foreign_key: { to_table: :organization_clients }
      t.integer :retention_guarantee_rate, null: false, default: 0
      t.string :name, null: false

      t.timestamps
      t.index [ :name, :client_id ], unique: true
    end
  end
end
