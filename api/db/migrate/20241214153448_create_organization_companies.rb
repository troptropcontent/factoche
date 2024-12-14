class CreateOrganizationCompanies < ActiveRecord::Migration[8.0]
  def change
    create_table :organization_companies do |t|
      t.string :name, null: false
      t.string :registration_number, null: false, index: { unique: true }
      t.string :email, null: false
      t.string :phone, null: false
      t.string :address_city, null: false
      t.string :address_street, null: false
      t.string :address_zipcode, null: false

      t.timestamps
    end
  end
end
