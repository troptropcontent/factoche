class CreateOrganizationMembers < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_members do |t|
      t.references :user, null: false, foreign_key: true
      t.references :company, null: false, foreign_key: { to_table: :organization_companies }

      t.timestamps
      t.index [ :user_id, :company_id ], unique: true
    end
  end
end
