class AddAddressFieldsToProjectsTable < ActiveRecord::Migration[8.0]
  def change
    add_column :organization_projects, :address_street, :string
    add_column :organization_projects, :address_zipcode, :string
    add_column :organization_projects, :address_city, :string
  end
end
