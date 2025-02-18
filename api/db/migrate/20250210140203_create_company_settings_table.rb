class CreateCompanySettingsTable < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_company_configs do |t|
      t.references :company, null: false, foreign_key: { to_table: "organization_companies" }
      t.jsonb :settings, null: false, default: {}
      t.timestamps
    end

    add_index :organization_company_configs, :settings, using: :gin
  end
end
