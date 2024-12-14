class CreateOrganizationClients < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_clients do |t|
      t.references :company, null: false, foreign_key: { to_table: :organization_companies }
      t.string :name, null: false
      t.string :registration_number, null: false
      t.string :email, null: false
      t.string :phone, null: false
      t.string :address_street, null: false
      t.string :address_city, null: false
      t.string :address_zipcode, null: false

      t.timestamps
      t.index [ :registration_number, :company_id ], unique: true
    end
  end
end
